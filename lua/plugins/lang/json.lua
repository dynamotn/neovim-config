local language = require('config.languages').json
local icons = require('config.defaults').icons

return vim.list_contains(_G.enabled_languages, 'json')
    and {
      {
        -- Schema
        'b0o/SchemaStore.nvim',
        ft = language.filetypes,
      },
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            jsonls = {
              before_init = function(_, client_config)
                client_config.settings.json.schemas = vim.tbl_deep_extend(
                  'force',
                  client_config.settings.json.schemas or {},
                  require('schemastore').json.schemas()
                )
              end,
              -- lazy-load schemastore when needed
              on_init = function(client)
                client.settings.json.schemas = vim.tbl_deep_extend(
                  'force',
                  client.settings.json.schemas or {},
                  require('schemastore').json.schemas()
                )
              end,
              settings = {
                json = {
                  format = {
                    enable = true,
                  },
                  validate = { enable = true },
                },
              },
            },
          },
        },
      },
    }
  or {}
