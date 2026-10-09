--- One `FileType` dispatcher for the lazy installation of language tooling
---
--- Treesitter parsers, LSP servers, linters and formatters are each installed
--- the first time one of their filetypes shows up. Registering an autocmd per
--- tool leaves Neovim a few hundred patterns to walk on every `FileType` event
--- and a wall of entries to read in `:autocmd FileType`, and it makes the
--- augroup name the only thing keeping two handlers apart -- a name two
--- languages can collide on, in which case one silently clears the other.
--- The handlers are kept in a table here instead, and one autocmd runs them.

local M = {}

local notify = require('util.notify').titled('Install')

---@alias DyFileTypeHandler fun(args: vim.api.keyset.create_autocmd.callback_args)

---@type table<string, DyFileTypeHandler[]>
local handlers = {}

local group

--- Run `handler` on `FileType` for each of `filetypes`
---
--- The filetype `*` matches every buffer, the way an autocmd pattern of the
--- same name does. A handler runs on every matching event, not just the first,
--- so it stays responsible for skipping the work it has already done.
---
--- Only buffers that hold a file count: a scratch buffer given a filetype --
--- a hover window, a plugin's own probe -- is no sign the language is used,
--- and installing for it reaches out to package managers nobody asked for.
---@param filetypes string[] Filetypes the handler is interested in
---@param handler DyFileTypeHandler
M.on_filetype = function(filetypes, handler)
  for _, filetype in ipairs(filetypes) do
    handlers[filetype] = handlers[filetype] or {}
    table.insert(handlers[filetype], handler)
  end

  if group then return end
  group = vim.api.nvim_create_augroup('dy_lazy_install', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    callback = function(args)
      if vim.bo[args.buf].buftype ~= '' then return end
      for _, filetype in ipairs({ args.match, '*' }) do
        for _, matched in ipairs(handlers[filetype] or {}) do
          -- Neovim reports a failing autocmd and carries on to the next one.
          -- A single dispatcher has to keep that up on its own, or one broken
          -- handler takes every later one down with it.
          local ok, err = pcall(matched, args)
          if not ok then notify(tostring(err), vim.log.levels.ERROR) end
        end
      end
    end,
  })
end

---@type table<string, true>
local attempted = {}

--- Install a Mason package once, the first time a handler asks for it
---
--- The dispatcher above runs its handlers on every matching `FileType`, and
--- `is_installed` stays false for a package that cannot be installed at all --
--- one held back by a registry pin, a missing toolchain, or a release its
--- package manager refuses. Asking again on each buffer then starts an install
--- per buffer: they race over the same Mason lockfile and bury the first, real
--- error under a wall of `ENOENT` on the lock. A package is tried once per
--- session instead, and the next attempt waits for a restart.
---@param package string Mason package name, optionally `name@version`
M.install_once = function(package)
  if attempted[package] then return end
  -- `MasonInstall` takes the version with the name, `is_installed` does not.
  local name = package:match('^(.-)@[^@]*$') or package
  if require('mason-registry').is_installed(name) then return end
  attempted[package] = true
  require('mason.api.command').MasonInstall({ package })
end

return M
