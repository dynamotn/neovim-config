local filetypes = require('languages.list').vue
local augend = require('dial.augend')

return vim.list_contains(_G.enabled_languages, 'vue')
    and {
      {
        'dial.nvim',
        opts = {
          groups = {
            vue = {
              augend.constant.new({ elements = { 'let', 'const' } }),
              augend.hexcolor.new({ case = 'lower' }),
              augend.hexcolor.new({ case = 'upper' }),
            },
          },
        },
      },
    }
  or {}
