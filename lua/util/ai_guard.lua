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

--- What became of each wrapper, for `:checkhealth util`
---@type table<string, 'guarded'|'missing'>
M.status = {}

--- Wrap `tbl[key]` with `wrapper(original, ...)`, once
---@param tbl table?
---@param key string|integer
---@param name string Shown when the function is missing
---@param wrapper fun(original: function, ...): ...
local function wrap(tbl, key, name, wrapper)
  if type(tbl) ~= 'table' or type(tbl[key]) ~= 'function' then
    M.status[name] = 'missing'
    vim.notify(
      name .. ' not found, left unguarded',
      vim.log.levels.WARN,
      { title = 'AI guard' }
    )
    return
  end
  M.status[name] = 'guarded'
  local original = tbl[key]
  tbl[key] = function(...) return wrapper(original, ...) end
end

--- Milliseconds the buffer has to settle before it is looked at again
---
--- A change event arrives per paste and per insert; the credential patterns
--- are cheap but they read the whole buffer, and a secret pasted now is no
--- more urgent a tenth of a second later. `DiagnosticChanged` is debounced
--- with them because a linter run ends in a burst of them.
local RECHECK_DELAY = 200

--- Detach Copilot from a buffer that becomes sensitive, and offer it back
---
--- `:saveas`, `:file` and `:set filetype` change what a buffer is without
--- reopening it, so `root_dir` is never asked again -- and neither a name nor
--- a filetype changes when a token is pasted into a file that was perfectly
--- ordinary a second ago, or when `betterleaks` reports one after its run.
--- All four are watched, so what the content check knows reaches Copilot too.
---
--- What was sent before the change is gone already; detaching stops every
--- later edit from following. The way back is watched too: a token deleted
--- again, or a waiver given, leaves an ordinary buffer that Copilot would
--- have attached to all along, so it is offered the buffer once more -- but
--- only when this guard is what took it away.
M.watch_copilot = function()
  local group =
    vim.api.nvim_create_augroup('dy_ai_guard_copilot', { clear = true })

  --- Ask Neovim to decide about Copilot again, the way opening the file does
  ---
  --- There is no public call that re-runs the resolution behind an enabled
  --- LSP configuration -- `root_dir`, the root markers, the whole of it --
  --- but the `FileType` event does, since that is what starts a server in
  --- the first place. The handlers of `util.lazy_install` are written to run
  --- on every matching event, and an ftplugin guards itself with
  --- `b:did_ftplugin`, so firing it again asks the question without redoing
  --- the work.
  ---@param bufnr integer
  local function reconsider(bufnr)
    vim.api.nvim_exec_autocmds('FileType', { buffer = bufnr, modeline = false })
  end

  ---@param bufnr integer
  local function reconcile(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    local sensitive_now = sensitive.is_sensitive(bufnr)

    -- Gone again: the token was deleted, the waiver given, the finding
    -- cleared. Copilot is only offered back when this guard is what took it
    -- away, never when the buffer was left without it for another reason.
    if not sensitive_now then
      if vim.b[bufnr].dy_ai_guard_detached then
        vim.b[bufnr].dy_ai_guard_detached = nil
        reconsider(bufnr)
      end
      return
    end

    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'copilot' })
    if #clients == 0 then return end
    for _, client in ipairs(clients) do
      vim.lsp.buf_detach_client(bufnr, client.id)
    end
    vim.b[bufnr].dy_ai_guard_detached = true
    refuse('Copilot')
  end

  vim.api.nvim_create_autocmd({ 'BufFilePost', 'FileType' }, {
    group = group,
    callback = function(args)
      -- `reconsider` fires `FileType`, so only the detaching half runs here:
      -- re-attaching from inside the event it fires would be a loop.
      if sensitive.is_sensitive(args.buf) then reconcile(args.buf) end
    end,
  })

  ---@type table<integer, true>
  local pending = {}
  vim.api.nvim_create_autocmd(
    { 'TextChanged', 'InsertLeave', 'DiagnosticChanged' },
    {
      group = group,
      callback = function(args)
        local bufnr = args.buf
        if pending[bufnr] then return end
        pending[bufnr] = true
        vim.defer_fn(function()
          pending[bufnr] = nil
          reconcile(bufnr)
        end, RECHECK_DELAY)
      end,
    }
  )
end

--- Guard every way Avante reads a buffer or a file
---
--- Avante has no switch like a `send_code`, so each place it reads is
--- wrapped: a question or an edit asked from a sensitive buffer carries its
--- selection, a file added to the chat is sent whole, and the model's own
--- tools go through one permission check before touching a path.
M.guard_avante = function()
  local ok_api, api = pcall(require, 'avante.api')
  for _, key in ipairs({ 'ask', 'edit' }) do
    wrap(ok_api and api or nil, key, 'Avante ' .. key, function(original, ...)
      if sensitive.is_sensitive(0) then return refuse('Avante ' .. key) end
      return original(...)
    end)
  end

  -- `@` picks, all buffers, and the current file added on open all end here
  local ok_selector, selector = pcall(require, 'avante.file_selector')
  wrap(
    ok_selector and selector or nil,
    'add_selected_file',
    'Avante add_selected_file',
    function(add, self, filepath, ...)
      if
        type(filepath) == 'string'
        and filepath ~= ''
        and sensitive.is_sensitive_path(filepath)
      then
        return refuse('Avante')
      end
      return add(self, filepath, ...)
    end
  )

  -- Asked by `view`, the edit tools and the rest before they touch a path.
  -- Turned down, the model is told it has no permission and carries on.
  local ok_helpers, helpers = pcall(require, 'avante.llm_tools.helpers')
  wrap(
    ok_helpers and helpers or nil,
    'has_permission_to_access',
    'Avante tool permission',
    function(allowed, abs_path, ...)
      if
        type(abs_path) == 'string' and sensitive.is_sensitive_path(abs_path)
      then
        return false
      end
      return allowed(abs_path, ...)
    end
  )

  -- The one reader behind selected files and the tools, for whatever reaches
  -- it without asking for permission first
  local ok_utils, utils = pcall(require, 'avante.utils')
  wrap(
    ok_utils and utils or nil,
    'read_file_from_buf_or_disk',
    'Avante file reader',
    function(read, filepath, ...)
      if
        type(filepath) == 'string' and sensitive.is_sensitive_path(filepath)
      then
        return nil, 'the file is sensitive'
      end
      return read(filepath, ...)
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

  -- The statusline icon asks for the Copilot client of the buffer, and a
  -- sensitive buffer has none: the icon vanished, as if Copilot were not
  -- running at all. Reported as `Inactive` instead, while Copilot runs for
  -- other buffers, so a buffer turned down on purpose shows as such.
  local ok_status, status = pcall(require, 'sidekick.status')
  wrap(
    ok_status and status or nil,
    'get',
    'sidekick status',
    function(get, buf, ...)
      local result = get(buf, ...)
      if result or not sensitive.is_sensitive(buf) then return result end
      local ok_config, config = pcall(require, 'sidekick.config')
      if
        ok_config
        and config.copilot.status.enabled
        and #config.get_clients() > 0
      then
        return { busy = false, kind = 'Inactive', message = 'sensitive file' }
      end
    end
  )
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
--- Asked of lazy.nvim itself rather than through `util.plugin`: this runs
--- from `plugin/`, which a `--clean` Neovim with this repository on its
--- runtimepath sources too, and there lazy.nvim is not set up. Without it
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

--- `:AiGuardCheck` and `:AiGuardAllow`
---
--- A buffer held back for its name says so by its name; one held back for
--- what is written in it does not, and the first sign of it is a chat that
--- answers nothing. `:AiGuardCheck` says what was found and where, and
--- `:AiGuardAllow` is the way past a pattern that matched something that is
--- not a credential -- for that buffer, for as long as it is open, and never
--- for a file the name rules already named.
M.commands = function()
  vim.api.nvim_create_user_command('AiGuardCheck', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local waived = sensitive.is_allowed(bufnr)
    local reasons = sensitive.reasons(bufnr, { ignore_waiver = true })
    if #reasons == 0 then
      return vim.notify(
        'Nothing holding this buffer back',
        vim.log.levels.INFO,
        { title = 'AI guard' }
      )
    end
    local headline = waived
        and 'Waived by :AiGuardAllow, and otherwise held back for:'
      or 'Held back from every AI integration:'
    vim.notify(
      headline .. '\n- ' .. table.concat(reasons, '\n- '),
      waived and vim.log.levels.INFO or vim.log.levels.WARN,
      { title = 'AI guard' }
    )
  end, { desc = 'Why this buffer is kept from the AI integrations' })

  vim.api.nvim_create_user_command('AiGuardAllow', function(args)
    local bufnr = vim.api.nvim_get_current_buf()
    if args.bang then
      sensitive.allow(bufnr, false)
      return vim.notify(
        'The content check is back on for this buffer',
        vim.log.levels.INFO,
        { title = 'AI guard' }
      )
    end
    if sensitive.is_sensitive_path(vim.api.nvim_buf_get_name(bufnr)) then
      return vim.notify(
        'Refused: this file is sensitive by its name, not by what is in it',
        vim.log.levels.ERROR,
        { title = 'AI guard' }
      )
    end
    sensitive.allow(bufnr)
    vim.notify(
      'This buffer may now be sent to the AI integrations; :AiGuardAllow! '
        .. 'takes it back',
      vim.log.levels.WARN,
      { title = 'AI guard' }
    )
  end, {
    bang = true,
    desc = 'Waive the content check for this buffer, or take it back with !',
  })
end

--- Install every guard: Copilot's now, the others as their plugin loads
M.setup = function()
  M.commands()
  M.watch_copilot()
  on_load('avante.nvim', M.guard_avante)
  on_load('sidekick.nvim', M.guard_sidekick)
  on_load('claudecode.nvim', M.guard_claudecode)
end

return M
