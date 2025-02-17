local filetypes = require('languages.list').python
local augend = require('dial.augend')

return vim.list_contains(_G.enabled_languages, 'python')
    and {
      {
        'dial.nvim',
        opts = {
          groups = {
            python = {
              augend.constant.new({
                elements = { 'and', 'or' },
                word = true,
                cyclic = true,
              }),
            },
          },
        },
      },
      {
        'nvim-treesitter',
        opts = {
          ensure_installed = {
            'python',
          },
        },
      },
    }
  or {}
