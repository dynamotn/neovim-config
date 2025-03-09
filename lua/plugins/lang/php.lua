local language = require('config.languages').php

return vim.list_contains(_G.enabled_languages, 'php')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            intelephense = {
              enabled = true,
            },
          },
        },
      },
      {
        -- Debug adapters & configurations
        'mfussenegger/nvim-dap',
        opts = function()
          local dap = require('dap')
          local path = require('mason-registry')
            .get_package('php-debug-adapter')
            :get_install_path()
          dap.adapters.php = {
            type = 'executable',
            command = 'node',
            args = { path .. '/extension/out/phpDebug.js' },
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
