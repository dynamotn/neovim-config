local language = require('config.languages').zig

return vim.list_contains(_G.enabled_languages, 'zig')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            zls = {},
          },
        },
      },
      {
        -- Test adapter
        'nvim-neotest/neotest',
        dependencies = {
          'lawrence-laz/neotest-zig',
          ft = language.filetypes,
        },
        opts = {
          adapters = {
            ['neotest-zig'] = {},
          },
        },
      },
    }
  or {}
