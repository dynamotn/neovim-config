local language = require('config.languages').elixir

return vim.list_contains(_G.enabled_languages, 'elixir')
    and {
      {
        -- Test adapter
        'nvim-neotest/neotest',
        dependencies = {
          'jfpedroza/neotest-elixir',
          ft = language.filetypes,
        },
        opts = {
          adapters = {
            ['neotest-elixir'] = {},
          },
        },
      },
    }
  or {}
