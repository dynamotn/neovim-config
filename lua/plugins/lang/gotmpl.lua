local language = require('config.languages').gotmpl
local languages = require('util.languages')

return vim.list_contains(_G.enabled_languages, 'gotmpl')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            gopls = {
              settings = {
                gopls = {
                  gofumpt = true,
                  codelenses = {
                    gc_details = false,
                    generate = true,
                    regenerate_cgo = true,
                    run_govulncheck = true,
                    test = true,
                    tidy = true,
                    upgrade_dependency = true,
                    vendor = true,
                  },
                  hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                  },
                  analyses = {
                    nilness = true,
                    unusedparams = true,
                    unusedwrite = true,
                    useany = true,
                  },
                  usePlaceholders = true,
                  completeUnimported = true,
                  staticcheck = true,
                  directoryFilters = {
                    '-.git',
                    '-.vscode',
                    '-.idea',
                    '-.vscode-test',
                    '-node_modules',
                  },
                  semanticTokens = false,
                },
              },
            },
          },
          setup = {
            gopls = function(_, opts)
              -- workaround for gopls not supporting semanticTokensProvider
              -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
              LazyVim.lsp.on_attach(function(client, _)
                if not client.server_capabilities.semanticTokensProvider then
                  local semantic =
                    client.config.capabilities.textDocument.semanticTokens
                  client.server_capabilities.semanticTokensProvider = {
                    full = true,
                    legend = {
                      tokenTypes = semantic.tokenTypes,
                      tokenModifiers = semantic.tokenModifiers,
                    },
                    range = true,
                  }
                end
              end, 'gopls')
              -- end workaround
            end,
          },
        },
      },
      {
        -- Filetype icons
        'echasnovski/mini.icons',
        opts = {
          filetype = {
            gotmpl = { glyph = '󰟓 ', hl = 'MiniIconsGrey' },
          },
        },
      },
      {
        -- Injection another language
        'nvim-treesitter/nvim-treesitter',
        opts = {
          custom_predicates = {
            ['is-bash-file?'] = '.*%.sh%.tmpl$',
            ['is-fish-file?'] = '.*%.fish%.tmpl$',
            ['is-yaml-file?'] = '.*%.ya?ml%.tmpl$',
            ['is-toml-file?'] = '.*%.toml%.tmpl$',
            ['is-ini-file?'] = '.*%.ini%.tmpl$',
            ['is-js-file?'] = '.*%.js%.tmpl$',
            ['is-python-file?'] = '.*%.py%.tmpl$',
            ['is-lua-file?'] = '.*%.lua%.tmpl$',
          },
        },
      },
    }
  or {}
