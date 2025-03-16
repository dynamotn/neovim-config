local language = require('config.languages').ruby

return vim.list_contains(_G.enabled_languages, 'ruby')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            ruby_lsp = {},
            harper_ls = {},
          },
        },
      },
      {
        -- Debug adapters & configurations
        'mfussenegger/nvim-dap',
        dependencies = {
          'suketa/nvim-dap-ruby',
          ft = language.filetypes,
          config = function() require('dap-ruby').setup() end,
        },
      },
      {
        -- Test adapter
        'nvim-neotest/neotest',
        dependencies = {
          'olimorris/neotest-rspec',
          ft = language.filetypes,
        },
        opts = {
          adapters = {
            ['neotest-rspec'] = {},
          },
        },
      },
    }
  or {}
