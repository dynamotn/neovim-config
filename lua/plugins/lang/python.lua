local language = require('config.languages').python

return vim.list_contains(DyNeo.enabled_languages, 'python')
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
          -- Not under `<leader>dP`, which is Pause and would wait for these
          keys = {
            {
              '<leader>dm',
              function() require('dap-python').test_method() end,
              ft = language.filetypes,
              desc = 'Debug Method',
            },
            {
              '<leader>dM',
              function() require('dap-python').test_class() end,
              ft = language.filetypes,
              desc = 'Debug Class',
            },
          },
          -- `debugpy-adapter` is looked up on `$PATH` as a session starts, so
          -- this holds before Mason has installed it too
          config = function() require('dap-python').setup('debugpy-adapter') end,
        },
      },
      {
        -- The adapter is nvim-dap-python's, which finds the project's own
        -- interpreter; mason-nvim-dap's would replace it with one that runs
        -- under debugpy's venv, and list its configurations a second time
        'jay-babu/mason-nvim-dap.nvim',
        optional = true,
        opts = { handlers = { python = function() end } },
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
    }
  or {}
