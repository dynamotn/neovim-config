local language = require('config.languages').csv

return vim.list_contains(_G.enabled_languages, 'csv')
    and {
      {
        -- Navigation in file
        'dynamotn/csv.vim',
        ft = language.filetypes,
      },
    }
  or {}
