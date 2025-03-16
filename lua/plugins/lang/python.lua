local language = require('config.languages').python

return vim.list_contains(_G.enabled_languages, 'python')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            pyright = {},
            ruff = {},
            harper_ls = {},
          },
        },
      },
      {
        -- Debug adapters & configurations
        'mfussenegger/nvim-dap',
        dependencies = {
          'mfussenegger/nvim-dap-python',
          keys = {
            {
              '<leader>dPt',
              function() require('dap-python').test_method() end,
              ft = language.filetypes,
              desc = 'Debug Method',
            },
            {
              '<leader>dPc',
              function() require('dap-python').test_class() end,
              ft = language.filetypes,
              desc = 'Debug Class',
            },
          },
          config = function()
            local registry = require('mason-registry')
            local dap_mapping = require('mason-nvim-dap.mappings.source')
            if
              registry.is_installed(dap_mapping.nvim_dap_to_package['python'])
            then
              require('dap-python').setup(
                LazyVim.get_pkg_path('debugpy', '/venv/bin/python')
              )
            end
          end,
        },
      },
      {
        -- Test adapter
        'nvim-neotest/neotest',
        dependencies = {
          'nvim-neotest/neotest-python',
          ft = language.filetypes,
        },
        opts = {
          adapters = {
            ['neotest-python'] = {
              dap = { justMyCode = false },
              runner = 'pytest',
            },
          },
        },
      },
      {
        -- Custom dial
        'monaqa/dial.nvim',
        opts = {
          groups = {
            python = language.dial(),
          },
        },
      },
    }
  or {}
