local language = require('config.languages').nginx

return vim.list_contains(_G.enabled_languages, 'nginx')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            nginx_language_server = {},
          },
        },
      },
    }
  or {}
