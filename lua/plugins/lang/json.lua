local language = require('config.languages').json

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
              -- lazy-load schemastore when needed
              on_new_config = function(new_config)
                new_config.settings.json.schemas = new_config.settings.json.schemas
                  or {}
                vim.list_extend(
                  new_config.settings.json.schemas,
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
