local language = require('config.languages').systemd

return vim.list_contains(_G.enabled_languages, 'systemd')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            systemd_ls = {},
          },
        },
      },
    }
  or {}
