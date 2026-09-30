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

---@alias DyFileTypeHandler fun(args: vim.api.keyset.create_autocmd.callback_args)

---@type table<string, DyFileTypeHandler[]>
local handlers = {}

local group

--- Run `handler` on `FileType` for each of `filetypes`
---
--- The filetype `*` matches every buffer, the way an autocmd pattern of the
--- same name does. A handler runs on every matching event, not just the first,
--- so it stays responsible for skipping the work it has already done.
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
      for _, filetype in ipairs({ args.match, '*' }) do
        for _, matched in ipairs(handlers[filetype] or {}) do
          -- Neovim reports a failing autocmd and carries on to the next one.
          -- A single dispatcher has to keep that up on its own, or one broken
          -- handler takes every later one down with it.
          local ok, err = pcall(matched, args)
          if not ok then
            vim.notify(
              tostring(err),
              vim.log.levels.ERROR,
              { title = 'lazy install' }
            )
          end
        end
      end
    end,
  })
end

return M
