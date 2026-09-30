local language = require('config.languages').yaml
local condition = vim.list_contains(_G.enabled_languages, 'yaml')
  or vim.list_contains(_G.enabled_languages, 'ansible')
local icons = require('config.defaults').icons

return condition
    and {
      {
        -- Schema
        --
        -- A library and nothing else: `on_init` below requires it when
        -- the server starts, and that is what loads it. Loading it on `ft`
        -- instead made lazy.nvim replay `FileType` for the buffer, running
        -- every handler of the filetype a second time.
        'b0o/SchemaStore.nvim',
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
              -- Hands SchemaStore to the server, lazy-loading it, and detects
              -- Kubernetes and cloud-init files the server has no schema for
              on_init = function(client)
                require('util.yaml_schema').on_init(client)
              end,
              keys = {
                {
                  '<leader>cy',
                  function() require('util.yaml_schema').select() end,
                  desc = 'Select YAML Schema',
                },
                {
                  '<leader>cY',
                  function() require('util.yaml_schema').select(0, true) end,
                  desc = 'Insert YAML Schema Modeline',
                },
              },
              settings = {
                redhat = { telemetry = { enabled = false } },
                yaml = {
                  keyOrdering = false,
                  format = {
                    enable = true,
                  },
                  validate = { enable = true },
                  -- Narrow the `kubernetes` schema down to the CRD of the
                  -- document, from the datreeio CRDs catalog
                  kubernetesCRDStore = { enable = true },
                  schemaStore = {
                    -- Must disable built-in schemaStore support to use
                    -- schemas from SchemaStore.nvim plugin
                    enable = false,
                    -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                    url = '',
                  },
                  customTags = {
                    -- Intrinsic Functions
                    '!Ref scalar',
                    '!GetAtt scalar',
                    '!GetAtt sequence',
                    '!Sub scalar',
                    '!Sub sequence',
                    '!Join sequence',
                    '!Select sequence',
                    '!Split sequence',
                    '!Base64 scalar',
                    '!Cidr sequence',
                    '!FindInMap sequence',
                    '!GetAZs scalar',
                    '!ImportValue scalar',

                    -- Condition Functions
                    '!And sequence',
                    '!Equals sequence',
                    '!If sequence',
                    '!Not sequence',
                    '!Or sequence',
                    '!Condition scalar',

                    -- Transform Functions
                    '!Transform mapping',

                    -- Additional AWS-specific tags
                    '!AWS::AccountId',
                    '!AWS::NoValue',
                    '!AWS::NotificationARNs',
                    '!AWS::Partition',
                    '!AWS::Region',
                    '!AWS::StackId',
                    '!AWS::StackName',
                    '!AWS::URLSuffix',

                    -- GitLab CI
                    '!reference sequence',
                  },
                },
              },
              filetypes = language.filetypes,
            },
            gitlab_ci_ls = {
              filetypes = { language.filetypes[2] },
            },
            gh_actions_ls = {
              filetypes = { language.filetypes[3] },
            },
            azure_pipelines_ls = {
              filetypes = { language.filetypes[4] },
            },
            docker_compose_language_service = {
              filetypes = { language.filetypes[5] },
            },
            helm_ls = {
              filetypes = { language.filetypes[6] },
            },
            vacuum = {
              filetypes = { language.filetypes[7] },
            },
          },
        },
      },
      {
        -- Lualine integration
        'nvim-lualine/lualine.nvim',
        opts = function(_, opts)
          table.insert(opts.sections.lualine_y, 1, {
            function(msg)
              msg = icons.treesitter.schema
              local bufnr = vim.api.nvim_get_current_buf()
              local clients = vim.lsp.get_clients({
                bufnr = bufnr,
                name = 'yamlls',
              })
              for _, client in pairs(clients) do
                local response, _ = client:request_sync(
                  ---@diagnostic disable-next-line: param-type-mismatch
                  'yaml/get/jsonSchema',
                  { vim.uri_from_bufnr(bufnr) },
                  20,
                  bufnr
                )
                if response and response.result and response.result[1] then
                  local schema = response.result[1]
                  if schema.uri then
                    return msg
                      .. require('util.yaml_schema').get_name(schema.uri)
                  else
                    return msg .. 'N/A'
                  end
                end
              end
              return msg
            end,
            cond = function()
              return vim.list_contains(language.filetypes, vim.bo.filetype)
            end,
          })
        end,
      },
    }
  or {}
