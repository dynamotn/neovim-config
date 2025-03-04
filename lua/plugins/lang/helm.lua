local language = require('config.languages').helm

return vim.list_contains(_G.enabled_languages, 'helm')
    and {
      {
        -- Filetype icons
        'echasnovski/mini.icons',
        opts = {
          filetype = {
            helm = { glyph = '', hl = 'MiniIconsGrey' },
          },
        },
      },
    }
  or {}
