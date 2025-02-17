local filetypes = require('languages.list').lua
local augend = require('dial.augend')

return vim.list_contains(_G.enabled_languages, 'lua')
    and {
      {
        'lazydev.nvim',
        ft = filetypes,
        init = function()
          _G.completion_sources = vim.tbl_extend('force', _G.completion_sources, {
            Lazydev = '「VIM」',
          })
        end,
      },
      {
        'dial.nvim',
        opts = {
          groups = {
            lua = {
              augend.constant.new({
                elements = { 'and', 'or' },
                word = true,
                cyclic = true,
              }),
            },
          },
        },
      },
    }
  or {}
