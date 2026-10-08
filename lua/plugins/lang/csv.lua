local language = require('config.languages').csv

return vim.list_contains(DyNeo.enabled_languages, 'csv')
    and {
      {
        -- Navigation and table view
        'hat0uma/csvview.nvim',
        ft = language.filetypes,
      },
    }
  or {}
