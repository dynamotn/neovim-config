local language = require('config.languages').python

return vim.list_contains(_G.enabled_languages, 'python')
    and {
      {
        -- Debug adapters & configurations
        'mfussenegger/nvim-dap',
        dependencies = {
          'mfussenegger/nvim-dap-python',
          keys = {
            {
              '<leader>dPt',
              function()
                require('dap-python').test_method()
              end,
              ft = language.filetypes,
              desc = 'Debug Method',
            },
            {
              '<leader>dPc',
              function()
                require('dap-python').test_class()
              end,
              ft = language.filetypes,
              desc = 'Debug Class',
            },
          },
          config = function()
            require('dap-python').setup(LazyVim.get_pkg_path('debugpy', '/venv/bin/python'))
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
