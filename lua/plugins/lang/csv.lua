local language = require('config.languages').csv

return vim.list_contains(_G.enabled_languages, 'csv')
    and {
      {
        -- Navigation and table view
        'hat0uma/csvview.nvim',
        ft = language.filetypes,
      },
    }
  or {}
