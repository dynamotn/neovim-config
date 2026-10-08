return vim.list_contains(DyNeo.enabled_languages, 'arduino')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            arduino_language_server = {},
          },
        },
      },
    }
  or {}
