local filetypes = require('languages.list').css
local augend = require('dial.augend')

return vim.list_contains(_G.enabled_languages, 'css')
    and {
      {
        'dial.nvim',
        opts = {
          groups = {
            css = {
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
