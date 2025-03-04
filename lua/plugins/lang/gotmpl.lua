local language = require('config.languages').gotmpl

return vim.list_contains(_G.enabled_languages, 'gotmpl')
    and {
      {
        -- Filetype icons
        'echasnovski/mini.icons',
        opts = {
          filetype = {
            gotmpl = { glyph = '󰟓 ', hl = 'MiniIconsGrey' },
          },
        },
      },
    }
  or {}
