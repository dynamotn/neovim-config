local language = require('config.languages').css

return vim.list_contains(_G.enabled_languages, 'css')
    and {
      {
        -- Custom dial
        'monaqa/dial.nvim',
        opts = {
          groups = {
            css = language.dial(),
          },
        },
      },
    }
  or {}
