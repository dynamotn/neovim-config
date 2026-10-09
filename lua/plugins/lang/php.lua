local language = require('config.languages').php

return vim.list_contains(DyNeo.enabled_languages, 'php')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            intelephense = {},
            harper_ls = {},
          },
        },
      },
      {
        -- Test adapter
        'nvim-neotest/neotest',
        dependencies = {
          'olimorris/neotest-phpunit',
          ft = language.filetypes,
        },
        opts = {
          adapters = {
            ['neotest-phpunit'] = {},
          },
        },
      },
    }
  or {}
