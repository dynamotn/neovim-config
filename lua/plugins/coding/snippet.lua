local snippet_dir = vim.fn.stdpath('config') .. '/snippets'

--- Shorten the two roots every snippet file sits under. The default of
--- `edit_snippet_files` only knows `$CONFIG` and a packer path, and a
--- lazy.nvim path is just as long as the packer one it replaces.
---@param path string
---@return string
local function format_path(path)
  path = path:gsub('^' .. vim.pesc(vim.fn.stdpath('config')), '$CONFIG')
  path =
    path:gsub('^' .. vim.pesc(vim.fn.stdpath('data') .. '/lazy'), '$PLUGINS')
  return path
end

--- `edit_snippet_files` only lists the files the loaders have already read, so
--- a filetype without one of its own offers nothing to pick. Add the file it
--- would live in: `:edit` on a path that does not exist yet opens a new buffer,
--- and writing it is all it takes for the snipmate loader to pick it up.
---@param ft string filetype the picker is listing files for
---@param paths string[] files the loaders know for `ft`
---@return table[] `{ display, path }` pairs appended to the picker
local function new_snippet_file(ft, paths)
  local path = ('%s/%s.snippets'):format(snippet_dir, ft)
  if vim.list_contains(paths, path) then return {} end
  return { { format_path(path) .. ' (new)', path } }
end

return {
  {
    -- Use Luasnip for Snipmate
    'L3MON4D3/LuaSnip',
    build = vim.fn.has('win32') == 0
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        config = function() require('luasnip.loaders.from_vscode').lazy_load() end,
      },
      {
        'honza/vim-snippets',
        config = function()
          require('luasnip.loaders.from_snipmate').lazy_load()
        end,
      },
    },
    keys = {
      {
        '<leader>cE',
        function()
          require('luasnip.loaders').edit_snippet_files({
            format = format_path,
            extend = new_snippet_file,
          })
        end,
        desc = 'Edit Snippets',
      },
    },
    opts = function()
      local actions = require('util.cmp').actions
      actions.snippet_forward = function()
        if require('luasnip').jumpable(1) then
          vim.schedule(function() require('luasnip').jump(1) end)
          return true
        end
      end
      actions.snippet_stop = function()
        if require('luasnip').expand_or_jumpable() then
          require('luasnip').unlink_current()
          return true
        end
      end
      return {
        history = true,
        delete_check_events = 'TextChanged',
      }
    end,
  },
  {
    'saghen/blink.cmp',
    opts = {
      snippets = {
        preset = 'luasnip',
      },
    },
  },
}
