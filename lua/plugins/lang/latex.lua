local language = require('config.languages').latex

return vim.list_contains(_G.enabled_languages, 'latex')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            ltex = {},
            texlab = {},
          },
        },
      },
    }
  or {}
