local language = require('config.languages').yaml
local condition = vim.list_contains(_G.enabled_languages, 'yaml')
  or vim.list_contains(_G.enabled_languages, 'ansible')
  or vim.list_contains(_G.enabled_languages, 'openapi')
return condition
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
            yamlls = {
              -- Have to add this for yamlls to understand that we support line folding
              capabilities = {
                textDocument = {
                  foldingRange = {
                    dynamicRegistration = false,
                    lineFoldingOnly = true,
                  },
                },
              },
              before_init = function(_, client_config)
                client_config.settings.yaml =
                  require('schemastore').yaml.schemas()
              end,
              -- lazy-load schemastore when needed
              on_init = function(client)
                client.settings.yaml.schemas = vim.tbl_deep_extend(
                  'force',
                  client.settings.yaml.schemas or {},
                  require('schemastore').yaml.schemas()
                )
              end,
              settings = {
                redhat = { telemetry = { enabled = false } },
                yaml = {
                  keyOrdering = false,
                  format = {
                    enable = true,
                  },
                  validate = { enable = true },
                  schemaStore = {
                    -- Must disable built-in schemaStore support to use
                    -- schemas from SchemaStore.nvim plugin
                    enable = false,
                    -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                    url = '',
                  },
                },
              },
            },
            gitlab_ci_ls = {
              filetypes = { 'yaml.gl-ci' },
            },
            gh_actions_ls = {
              filetypes = { 'yaml.gh-action' },
            },
            azure_pipelines_ls = {
              filetypes = { 'yaml.az-pl' },
            },
            docker_compose_language_service = {
              filetypes = { 'yaml.docker-compose' },
            },
          },
        },
      },
    }
  or {}
