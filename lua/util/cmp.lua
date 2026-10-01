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
    r = { 'cmp_r' },
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

return M
