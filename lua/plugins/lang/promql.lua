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
      {
        -- Map termuxls with termux-language-server in mason
        'mason-org/mason-lspconfig.nvim',
        config = function()
          local server = require('mason-lspconfig.mappings.server')
          server.lspconfig_to_package['promqlls'] = 'promql-langserver'
          server.package_to_lspconfig['promql-langserver'] = 'promqlls'
        end,
      },
    }
  or {}
