local language = require('config.languages').dockerfile

return vim.list_contains(_G.enabled_languages, 'dockerfile')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            dockerls = {},
          },
        },
      },
    }
  or {}
