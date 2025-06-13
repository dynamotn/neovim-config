local language = require('config.languages').promql

return vim.list_contains(_G.enabled_languages, 'promql')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            promqlls = {},
          },
          module = {
            promqlls = 'tools.lsp.promqlls',
          },
        },
      },
    }
  or {}
