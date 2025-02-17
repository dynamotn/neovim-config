local filetypes = require('languages.list').sass
local augend = require('dial.augend')

return vim.list_contains(_G.enabled_languages, 'sass')
    and {
      {
        'dial.nvim',
        opts = {
          groups = {
            sass = {
              augend.hexcolor.new({
                case = 'lower',
              }),
              augend.hexcolor.new({
                case = 'upper',
              }),
            },
          },
        },
      },
    }
  or {}
