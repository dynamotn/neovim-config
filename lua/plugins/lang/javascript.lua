local filetypes = require('languages.list').javascript
local augend = require('dial.augend')

return vim.list_contains(_G.enabled_languages, 'javascript')
    and {
      {
        'dial.nvim',
        opts = {
          groups = {
            javascript = {
              augend.constant.new({ elements = { 'let', 'const' } }),
            },
          },
        },
      },
      {
        'nvim-treesitter',
        opts = {
          ensure_installed = {
            'javascript',
          },
        },
      },
    }
  or {}
