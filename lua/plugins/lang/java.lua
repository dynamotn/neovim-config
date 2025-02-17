local filetypes = require('languages.list').java
local augend = require('dial.augend')

return vim.list_contains(_G.enabled_languages, 'java')
    and {
      {
        'dial.nvim',
        opts = {
          groups = {
            java = {
              augend.constant.new({
                elements = { 'public', 'protected', 'private' },
                word = false,
                cyclic = true,
              }),
            },
          },
        },
      },
    }
  or {}
