local language = require('config.languages').solidity

return vim.list_contains(_G.enabled_languages, 'solidity')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            solang = {},
          },
        },
      },
    }
  or {}
