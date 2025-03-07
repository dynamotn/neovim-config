local language = require('config.languages').gotmpl
local languages = require('util.languages')

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
      {
        -- Injection another language
        'nvim-treesitter/nvim-treesitter',
        opts = {
          custom_predicates = {
            ['is-bash-file?'] = '.*%.sh%.tmpl$',
            ['is-fish-file?'] = '.*%.fish%.tmpl$',
            ['is-yaml-file?'] = '.*%.ya?ml%.tmpl$',
            ['is-toml-file?'] = '.*%.toml%.tmpl$',
            ['is-ini-file?'] = '.*%.ini%.tmpl$',
            ['is-js-file?'] = '.*%.js%.tmpl$',
            ['is-python-file?'] = '.*%.py%.tmpl$',
            ['is-lua-file?'] = '.*%.lua%.tmpl$',
          },
        },
      },
    }
  or {}
