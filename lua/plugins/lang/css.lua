return vim.list_contains(DyNeo.enabled_languages, 'css')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            tailwindcss = {},
          },
        },
      },
    }
  or {}
