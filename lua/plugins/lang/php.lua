local language = require('config.languages').php

return vim.list_contains(_G.enabled_languages, 'php')
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
        -- Debug adapters & configurations
        'mfussenegger/nvim-dap',
        opts = function()
          local dap = require('dap')
          dap.adapters.php = {
            type = 'executable',
            command = 'php-debug-adapter',
            args = {},
          }
        end,
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
