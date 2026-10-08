local Plugin = require('util.plugin')

local M = {}

--- Whether `path` is an existing unix socket
---@param path string
---@return boolean
local function is_socket(path)
  local stat = vim.uv.fs_stat(path)
  return stat ~= nil and stat.type == 'socket'
end

--- Whether the terminal or multiplexer behind each pane source is reachable.
--- Their environment variables outlive the process that set them (e.g. a
--- long-lived zellij session started from an old kitty), and a source
--- talking to a dead socket either errors out or spawns a failing command on
--- every completion.
---@type table<string, fun(): boolean>
local pane_source_reachable = {
  -- blink_cmp_kitty fails to decode the empty `kitty @ ls` output
  kitty = function()
    local listen_on = vim.env.KITTY_LISTEN_ON
    if not vim.env.KITTY_WINDOW_ID or not listen_on then return false end
    if vim.fn.executable('kitty') == 0 then return false end
    local path = listen_on:match('^unix:(.+)$')
    -- Abstract sockets (`unix:@name`) and TCP have nothing on disk to check
    if not path or vim.startswith(path, '@') then return true end
    return is_socket(path)
  end,
  -- `$TMUX` is `<socket>,<pid>,<session>`
  tmux = function()
    local tmux = vim.env.TMUX
    if not tmux or vim.fn.executable('tmux') == 0 then return false end
    return is_socket(tmux:match('^([^,]+)') or '')
  end,
  -- The zellij socket lives under a versioned directory that also depends on
  -- `ZELLIJ_SOCKET_DIR` or `TMPDIR`, so only its environment is checked
  zellij = function()
    return vim.env.ZELLIJ ~= nil
      and vim.env.ZELLIJ_SESSION_NAME ~= nil
      and vim.fn.executable('zellij') == 1
  end,
}

--- Setup default sources of cmp
M.setup_default_sources = function()
  local success, node = pcall(vim.treesitter.get_node)
  if
    success
    and node
    and vim.tbl_contains(
      { 'comment', 'line_comment', 'block_comment' },
      node:type()
    )
  then
    return M.sources('comment')
  else
    return M.sources('*')
  end
end

--- Sources for filetype
---@param filetype string Filetype to enable sources. `*` for undefined
M.sources = function(filetype)
  local common_sources = {
    'lsp',
    'path',
    'project_path',
    'fuzzy_path',
    'snippets',
    'buffer',
    'calc',
    'emoji',
    'dynamic',
    'dictionary',
  }
  for _, source in ipairs({ 'tmux', 'zellij', 'kitty' }) do
    if pane_source_reachable[source]() then
      table.insert(common_sources, source)
    end
  end
  local unique_sources = {
    markdown = { 'nerdfont' },
    typst = { 'nerdfont' },
    blade = { 'blade-nav', 'laravel' },
    clojure = { 'conjure' },
    fish = { 'fish' },
    julia = { 'latex_symbols' },
    sql = { 'dadbod', 'sql' },
    lua = { 'lazydev' },
  }

  if filetype == 'comment' then
    return { 'buffer', 'ripgrep', 'dictionary', 'emoji', 'nerdfont', 'dynamic' }
  elseif filetype == 'dap' then
    return { 'dap', 'buffer', 'ripgrep' }
  elseif vim.list_contains({ 'gitcommit', 'gitrebase', 'octo' }, filetype) then
    return {
      'git',
      'lsp',
      'snippets',
      'buffer',
      'emoji',
      'nerdfont',
      'dynamic',
      'dictionary',
    }
  elseif vim.list_contains(vim.tbl_keys(unique_sources), filetype) then
    local result = {}
    vim.list_extend(result, unique_sources[filetype])
    return vim.list_extend(result, common_sources)
  elseif filetype == '*' then
    return common_sources
  end
end

---@alias BlinkAction fun(): boolean?

--- Named actions for completion keys, filled in by the snippet and AI
--- plugins as they load. An action returns true when it handled the key.
---@type table<string, BlinkAction>
M.actions = {
  snippet_forward = function()
    if vim.snippet.active({ direction = 1 }) then
      vim.schedule(function() vim.snippet.jump(1) end)
      return true
    end
  end,
  snippet_stop = function()
    if vim.snippet then vim.snippet.stop() end
  end,
}

--- Key handler running `actions` in turn until one handles the key, then
--- `fallback`
---@param actions string[]
---@param fallback? string|fun()
function M.map(actions, fallback)
  return function()
    for _, name in ipairs(actions) do
      if M.actions[name] and M.actions[name]() then return true end
    end
    return type(fallback) == 'function' and fallback() or fallback
  end
end

---@alias Placeholder { n: number, text: string }

---@param snippet string
---@param fn fun(placeholder: Placeholder): string
---@return string
function M.snippet_replace(snippet, fn)
  return snippet:gsub('%$%b{}', function(m)
    local n, name = m:match('^%${(%d+):(.+)}$')
    return n and fn({ n = n, text = name }) or m
  end) or snippet
end

--- Snippet text with its nested placeholders resolved
---@param snippet string
---@return string
function M.snippet_preview(snippet)
  local ok, parsed = pcall(
    function() return vim.lsp._snippet_grammar.parse(snippet) end
  )
  return ok and tostring(parsed)
    or M.snippet_replace(
      snippet,
      function(placeholder) return M.snippet_preview(placeholder.text) end
    ):gsub('%$0', '')
end

--- Snippet with nested placeholders flattened, which `vim.snippet` can
--- expand
---@param snippet string
---@return string
function M.snippet_fix(snippet)
  local texts = {} ---@type table<number, string>
  return M.snippet_replace(snippet, function(placeholder)
    texts[placeholder.n] = texts[placeholder.n]
      or M.snippet_preview(placeholder.text)
    return '${' .. placeholder.n .. ':' .. texts[placeholder.n] .. '}'
  end)
end

--- `vim.snippet.expand` that falls back to the flattened snippet, and keeps
--- the top-level session: native sessions do not nest
---@param snippet string
function M.expand(snippet)
  local session = vim.snippet.active() and vim.snippet._session or nil

  local ok, err = pcall(vim.snippet.expand, snippet)
  if not ok then
    local fixed = M.snippet_fix(snippet)
    ok = pcall(vim.snippet.expand, fixed)
    local msg = ok
        and 'Failed to parse snippet,\nbut was able to fix it automatically.'
      or ('Failed to parse snippet.\n' .. err)
    Plugin[ok and 'warn' or 'error'](
      ('%s\n```%s\n%s\n```'):format(msg, vim.bo.filetype, snippet),
      { title = 'vim.snippet' }
    )
  end

  if session then vim.snippet._session = session end
end

--- Whether blink's own `cmdline` source completes a path at the cursor: the
--- argument of `:edit`, `:cd`, `:find`, a `complete=file` command, `:!./`.
--- It then lists the entries of the directory typed so far, which is just
--- what `path` would list a second time.
---@return boolean
function M.cmdline_completes_path()
  local ok, utils = pcall(require, 'blink.cmp.sources.cmdline.utils')
  if not ok then return false end
  return utils.is_path_completion(
    utils.get_completion_type('cmdline'),
    vim.fn.getcmdline()
  )
end

--- Sources of the command line: the `cmdline` source, then paths and the
--- words of the buffers; `path` only where `cmdline` does not complete paths
--- itself. `fuzzy_path` stays either way: it finds files anywhere below,
--- under their whole relative path.
---@return string[]
function M.cmdline_sources()
  local type = vim.fn.getcmdtype()
  -- Search forward and backward
  if type == '/' or type == '?' then return { 'buffer' } end
  -- Commands, and `input()` that may complete like one
  if type == ':' or type == '@' then
    if M.cmdline_completes_path() then
      return { 'cmdline', 'fuzzy_path', 'buffer' }
    end
    return { 'cmdline', 'fuzzy_path', 'path', 'buffer' }
  end
  return {}
end

return M
