--- Keep sensitive files out of every AI integration, not only Copilot
---
--- `root_dir` stops Copilot from attaching to a sensitive buffer, but that is
--- decided once, when the buffer is opened, and it says nothing about the
--- other ways a buffer leaves the editor: a chat that is handed a file, a
--- selection that follows the cursor into Claude Code, a prompt sent to a CLI
--- tool. Each integration is guarded here at the one place it reads a buffer
--- or a path, against the list in `util.sensitive`.
---
--- The plugins expose no hook for most of this, so their functions are
--- wrapped. A wrapper that no longer finds what it wraps leaves the plugin as
--- it is and says so, rather than breaking it on an upstream rename.

local sensitive = require('util.sensitive')

local M = {}

---@param what string
local function refuse(what)
  vim.notify(
    what .. ' refused: the file is sensitive',
    vim.log.levels.WARN,
    { title = 'AI guard' }
  )
end

--- Wrap `tbl[key]` with `wrapper(original, ...)`, once
---@param tbl table?
---@param key string|integer
---@param name string Shown when the function is missing
---@param wrapper fun(original: function, ...): ...
local function wrap(tbl, key, name, wrapper)
  if type(tbl) ~= 'table' or type(tbl[key]) ~= 'function' then
    vim.notify(
      name .. ' not found, left unguarded',
      vim.log.levels.WARN,
      { title = 'AI guard' }
    )
    return
  end
  local original = tbl[key]
  tbl[key] = function(...) return wrapper(original, ...) end
end

--- Detach Copilot from a buffer that becomes sensitive after it attached
---
--- `:saveas`, `:file` and `:set filetype` change what a buffer is without
--- reopening it, so `root_dir` is never asked again. What was sent before the
--- change is gone already; detaching stops every later edit from following.
M.watch_copilot = function()
  vim.api.nvim_create_autocmd({ 'BufFilePost', 'FileType' }, {
    group = vim.api.nvim_create_augroup(
      'dy_ai_guard_copilot',
      { clear = true }
    ),
    callback = function(args)
      local clients =
        vim.lsp.get_clients({ bufnr = args.buf, name = 'copilot' })
      if #clients == 0 or not sensitive.is_sensitive(args.buf) then return end
      for _, client in ipairs(clients) do
        vim.lsp.buf_detach_client(args.buf, client.id)
      end
      refuse('Copilot')
    end,
  })
end

--- CodeCompanion's own switch for sending code, as `opts.send_code`
---
--- It is asked from the chat buffer as often as from the file, so the buffer a
--- chat was opened from counts as well as the current one.
---@return boolean
M.codecompanion_send_code = function()
  local buffers = { vim.api.nvim_get_current_buf() }
  -- Set by CodeCompanion to the buffer its chat was last opened from
  ---@diagnostic disable-next-line: undefined-field
  local context = _G.codecompanion_current_context
  if type(context) == 'number' then table.insert(buffers, context) end
  local ok, codecompanion = pcall(require, 'codecompanion')
  local chat = ok and codecompanion.buf_get_chat(buffers[1]) or nil
  if chat and chat.buffer_context then
    table.insert(buffers, chat.buffer_context.bufnr)
  end

  for _, bufnr in ipairs(buffers) do
    if sensitive.is_sensitive(bufnr) then return false end
  end
  return true
end

--- Guard what `send_code` cannot see: a file or buffer picked in a chat, and
--- a file the model asks to read
M.guard_codecompanion = function()
  local prefix = 'codecompanion.interactions.'
  for _, kind in ipairs({ 'file', 'buffer' }) do
    local ok, slash = pcall(require, prefix .. 'shared.slash_commands.' .. kind)
    wrap(
      ok and slash or nil,
      'output',
      'CodeCompanion /' .. kind,
      function(output, self, selected, ...)
        local picked = selected or {}
        if
          (picked.bufnr and sensitive.is_sensitive(picked.bufnr))
          or (picked.path and sensitive.is_sensitive_path(picked.path))
        then
          refuse('CodeCompanion /' .. kind)
          return false
        end
        return output(self, selected, ...)
      end
    )
  end

  local ok, read_file = pcall(require, prefix .. 'chat.tools.builtin.read_file')
  wrap(
    ok and read_file.cmds or nil,
    1,
    'CodeCompanion read_file',
    function(read, self, args, opts)
      if
        args
        and args.filepath
        and sensitive.is_sensitive_path(args.filepath)
      then
        -- Answered like a failed read, so the model is told and carries on.
        return opts.output_cb({
          status = 'error',
          data = string.format(
            'Reading `%s` is not allowed: the file is sensitive',
            args.filepath
          ),
        })
      end
      return read(self, args, opts)
    end
  )
end

--- Refuse to send a prompt to a CLI tool from a sensitive buffer, since
--- `{this}`, `{selection}` and friends expand to its content
M.guard_sidekick = function()
  local ok, cli = pcall(require, 'sidekick.cli')
  wrap(ok and cli or nil, 'send', 'sidekick send', function(send, ...)
    if sensitive.is_sensitive(0) then return refuse('sidekick') end
    return send(...)
  end)
end

--- Keep Claude Code's view of the editor off sensitive buffers
---
--- The selection is pushed to Claude Code on every cursor move, text and all,
--- without anything being asked for. Skipping the update in a sensitive
--- buffer leaves Claude Code with the last selection made elsewhere.
M.guard_claudecode = function()
  local ok, selection = pcall(require, 'claudecode.selection')
  wrap(
    ok and selection or nil,
    'update_selection',
    'claudecode selection',
    function(update, ...)
      if sensitive.is_sensitive(0) then return end
      return update(...)
    end
  )

  local ok_main, claudecode = pcall(require, 'claudecode')
  wrap(
    ok_main and claudecode or nil,
    'send_at_mention',
    'claudecode send_at_mention',
    function(send, file_path, ...)
      if file_path and sensitive.is_sensitive_path(file_path) then
        refuse('Claude Code')
        return false, 'the file is sensitive'
      end
      return send(file_path, ...)
    end
  )
end

--- Run `fn` once lazy.nvim has loaded `name`, or now if it already has
---
--- Asked of lazy.nvim itself rather than of the `LazyVim` global: this runs
--- from `plugin/`, which a `--clean` Neovim with this repository on its
--- runtimepath sources too, and there neither is set up. Without lazy.nvim
--- none of the guarded plugins can load, so there is nothing to guard.
---@param name string
---@param fn fun()
local function on_load(name, fn)
  local ok, config = pcall(require, 'lazy.core.config')
  if not ok or not config.plugins then return end
  local plugin = config.plugins[name]
  if plugin and plugin._.loaded then return fn() end
  vim.api.nvim_create_autocmd('User', {
    pattern = 'LazyLoad',
    callback = function(event)
      if event.data ~= name then return end
      fn()
      return true
    end,
  })
end

--- Install every guard: Copilot's now, the others as their plugin loads
M.setup = function()
  M.watch_copilot()
  on_load('codecompanion.nvim', M.guard_codecompanion)
  on_load('sidekick.nvim', M.guard_sidekick)
  on_load('claudecode.nvim', M.guard_claudecode)
end

return M
