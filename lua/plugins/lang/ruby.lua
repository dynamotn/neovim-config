local language = require('config.languages').ruby

return vim.list_contains(DyNeo.enabled_languages, 'ruby')
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
        -- Loaded with nvim-dap, not on `ft`: the adapter requires nvim-dap, so
        -- loading it with the filetype brought the whole debugger along on
        -- every buffer of the language.
        dependencies = {
          'suketa/nvim-dap-ruby',
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
