local language = require('config.languages').bicep

return vim.list_contains(_G.enabled_languages, 'bicep')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            bicep = {},
          },
        },
      },
    }
  or {}
