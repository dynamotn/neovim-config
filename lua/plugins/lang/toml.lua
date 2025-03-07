local language = require('config.languages').toml

return vim.list_contains(_G.enabled_languages, 'toml')
    and {
      {
        -- Mise injection
        'nvim-treesitter/nvim-treesitter',
        opts = {
          custom_predicates = {
            ['is-mise?'] = '.*mise.*%.toml$',
          },
        },
      },
    }
  or {}
