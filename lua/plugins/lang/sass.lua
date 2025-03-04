local language = require('config.languages').sass
local augend = require('dial.augend')

return vim.list_contains(_G.enabled_languages, 'sass')
    and {
      {
        -- Custom dial
        'monaqa/dial.nvim',
        opts = {
          groups = {
            sass = language.dial(),
          },
        },
      },
    }
  or {}
