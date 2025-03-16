local language = require('config.languages').openapi

return vim.list_contains(_G.enabled_languages, 'openapi')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            vacuum = {},
          },
        },
      },
    }
  or {}
