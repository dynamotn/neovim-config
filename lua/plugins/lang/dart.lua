local language = require('config.languages').dart

return vim.list_contains(_G.enabled_languages, 'dart')
    and {
      {
        -- Flutter toolbox: runner, devices, outline, and the Dart LSP
        'akinsho/flutter-tools.nvim',
        ft = language.filetypes,
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {},
      },
      {
        -- `flutter-tools` starts `dartls` with its own settings, so keep
        -- lspconfig from starting a second one; the entry in
        -- `config.languages` is what installs and documents the server.
        'neovim/nvim-lspconfig',
        opts = {
          setup = {
            dartls = function() return true end,
          },
        },
      },
      {
        -- Test adapter
        'nvim-neotest/neotest',
        dependencies = {
          'sidlatau/neotest-dart',
          ft = language.filetypes,
        },
        opts = {
          adapters = {
            ['neotest-dart'] = {},
          },
        },
      },
    }
  or {}
