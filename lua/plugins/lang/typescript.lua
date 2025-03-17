local language = require('config.languages').typescript
local condition = vim.list_contains(_G.enabled_languages, 'typescript')
  or vim.list_contains(_G.enabled_languages, 'angular')
  or vim.list_contains(_G.enabled_languages, 'vue')
return condition
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            vtsls = {
              settings = {
                complete_function_calls = true,
                vtsls = {
                  enableMoveToFileCodeAction = true,
                  autoUseWorkspaceTsdk = true,
                  experimental = {
                    maxInlayHintLength = 30,
                    completion = {
                      enableServerSideFuzzyMatch = true,
                    },
                  },
                },
                typescript = {
                  updateImportsOnFileMove = { enabled = 'always' },
                  suggest = {
                    completeFunctionCalls = true,
                  },
                  inlayHints = {
                    enumMemberValues = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    parameterNames = { enabled = 'literals' },
                    parameterTypes = { enabled = true },
                    propertyDeclarationTypes = { enabled = true },
                    variableTypes = { enabled = false },
                  },
                },
              },
              keys = {
                {
                  'gD',
                  function()
                    local params = vim.lsp.util.make_position_params()
                    LazyVim.lsp.execute({
                      command = 'typescript.goToSourceDefinition',
                      arguments = { params.textDocument.uri, params.position },
                      open = true,
                    })
                  end,
                  desc = 'Goto Source Definition',
                },
                {
                  'gR',
                  function()
                    LazyVim.lsp.execute({
                      command = 'typescript.findAllFileReferences',
                      arguments = { vim.uri_from_bufnr(0) },
                      open = true,
                    })
                  end,
                  desc = 'File References',
                },
                {
                  '<leader>co',
                  LazyVim.lsp.action['source.organizeImports'],
                  desc = 'Organize Imports',
                },
                {
                  '<leader>cM',
                  LazyVim.lsp.action['source.addMissingImports.ts'],
                  desc = 'Add missing imports',
                },
                {
                  '<leader>cu',
                  LazyVim.lsp.action['source.removeUnused.ts'],
                  desc = 'Remove unused imports',
                },
                {
                  '<leader>cD',
                  LazyVim.lsp.action['source.fixAll.ts'],
                  desc = 'Fix all diagnostics',
                },
                {
                  '<leader>cV',
                  function()
                    LazyVim.lsp.execute({
                      command = 'typescript.selectTypeScriptVersion',
                    })
                  end,
                  desc = 'Select TS workspace version',
                },
              },
            },
            harper_ls = {},
          },
          setup = {
            vtsls = function(_, opts)
              LazyVim.lsp.on_attach(function(client, buffer)
                client.commands['_typescript.moveToFileRefactoring'] = function(
                  command,
                  ctx
                )
                  ---@type string, string, lsp.Range
                  local action, uri, range = unpack(command.arguments)

                  local function move(newf)
                    client.request('workspace/executeCommand', {
                      command = command.command,
                      arguments = { action, uri, range, newf },
                    })
                  end

                  local fname = vim.uri_to_fname(uri)
                  client.request('workspace/executeCommand', {
                    command = 'typescript.tsserverRequest',
                    arguments = {
                      'getMoveToRefactoringFileSuggestions',
                      {
                        file = fname,
                        startLine = range.start.line + 1,
                        startOffset = range.start.character + 1,
                        endLine = range['end'].line + 1,
                        endOffset = range['end'].character + 1,
                      },
                    },
                  }, function(_, result)
                    ---@type string[]
                    local files = result.body.files
                    table.insert(files, 1, 'Enter new path...')
                    vim.ui.select(files, {
                      prompt = 'Select move destination:',
                      format_item = function(f)
                        return vim.fn.fnamemodify(f, ':~:.')
                      end,
                    }, function(f)
                      if f and f:find('^Enter new path') then
                        vim.ui.input({
                          prompt = 'Enter move destination:',
                          default = vim.fn.fnamemodify(fname, ':h') .. '/',
                          completion = 'file',
                        }, function(newf)
                          return newf and move(newf)
                        end)
                      elseif f then
                        move(f)
                      end
                    end)
                  end)
                end
              end, 'vtsls')
              -- copy typescript settings to javascript
              opts.settings.javascript = vim.tbl_deep_extend(
                'force',
                {},
                opts.settings.typescript,
                opts.settings.javascript or {}
              )
            end,
          },
        },
      },
      {
        -- Extend LSP config of vtsls by plugin for Typescript and Javascript
        'neovim/nvim-lspconfig',
        opts = function(_, opts)
          LazyVim.extend(opts.servers.vtsls, 'filetypes', language.filetypes)
        end,
      },
      {
        -- Debug adapters & configurations
        'mfussenegger/nvim-dap',
        opts = function()
          local dap = require('dap')
          if not dap.adapters['pwa-node'] then
            require('dap').adapters['pwa-node'] = {
              type = 'server',
              host = 'localhost',
              port = '${port}',
              executable = {
                command = 'node',
                args = {
                  LazyVim.get_pkg_path(
                    'js-debug-adapter',
                    '/js-debug/src/dapDebugServer.js',
                    { warn = false }
                  ),
                  '${port}',
                },
              },
            }
          end
          if not dap.adapters['node'] then
            dap.adapters['node'] = function(cb, config)
              if config.type == 'node' then config.type = 'pwa-node' end
              local nativeAdapter = dap.adapters['pwa-node']
              if type(nativeAdapter) == 'function' then
                nativeAdapter(cb, config)
              else
                cb(nativeAdapter)
              end
            end
          end

          local vscode = require('dap.ext.vscode')
          vscode.type_to_filetypes['node'] = language.filetypes
          vscode.type_to_filetypes['pwa-node'] = language.filetypes

          for _, filetype in ipairs(language.filetypes) do
            if not dap.configurations[filetype] then
              dap.configurations[filetype] = {
                {
                  type = 'pwa-node',
                  request = 'launch',
                  name = 'Launch file',
                  program = '${file}',
                  cwd = '${workspaceFolder}',
                },
                {
                  type = 'pwa-node',
                  request = 'attach',
                  name = 'Attach',
                  processId = require('dap.utils').pick_process,
                  cwd = '${workspaceFolder}',
                },
              }
            end
          end
        end,
      },
      {
        -- Test adapter
        'nvim-neotest/neotest',
        dependencies = {
          {
            'nvim-neotest/neotest-jest',
            ft = language.filetypes,
          },
          {
            'marilari88/neotest-vitest',
            ft = language.filetypes,
          },
          {
            'thenbe/neotest-playwright',
            ft = language.filetypes,
          },
        },
        opts = {
          adapters = {
            ['neotest-jest'] = {
              jestCommand = 'npm test --',
              jestConfigFile = 'custom.jest.config.ts',
              env = { CI = true },
              cwd = function(_) return require('lazyvim.util.root').get() end,
            },
          },
        },
      },
      {
        -- Filetype icons
        'echasnovski/mini.icons',
        opts = {
          file = {
            ['.eslintrc.js'] = { glyph = '󰱺 ', hl = 'MiniIconsYellow' },
            ['.node-version'] = { glyph = ' ', hl = 'MiniIconsGreen' },
            ['.prettierrc'] = { glyph = '', hl = 'MiniIconsPurple' },
            ['.yarnrc.yml'] = { glyph = ' ', hl = 'MiniIconsBlue' },
            ['eslint.config.js'] = { glyph = '󰱺 ', hl = 'MiniIconsYellow' },
            ['package.json'] = { glyph = ' ', hl = 'MiniIconsGreen' },
            ['tsconfig.json'] = { glyph = ' ', hl = 'MiniIconsAzure' },
            ['tsconfig.build.json'] = { glyph = ' ', hl = 'MiniIconsAzure' },
            ['yarn.lock'] = { glyph = ' ', hl = 'MiniIconsBlue' },
          },
        },
      },
    }
  or {}
