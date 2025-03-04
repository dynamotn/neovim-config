local language = require('config.languages').arduino
return vim.list_contains(_G.enabled_languages, 'arduino')
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
