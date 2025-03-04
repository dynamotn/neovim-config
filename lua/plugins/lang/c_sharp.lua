local language = require('config.languages').c_sharp

return vim.list_contains(_G.enabled_languages, 'c_sharp')
    and {
      {
        -- Extended LSP
        'Hoffs/omnisharp-extended-lsp.nvim',
        ft = language.filetypes,
      },
      {
        -- Config for LSP
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            omnisharp = {
              handlers = {
                ['textDocument/definition'] = function(...)
                  return require('omnisharp_extended').handler(...)
                end,
              },
              keys = {
                {
                  'gd',
                  function()
                    require('omnisharp_extended').lsp_definitions()
                  end,
                  desc = 'Goto Definition',
                },
              },
              enable_roslyn_analyzers = true,
              organize_imports_on_format = true,
              enable_import_completion = true,
            },
          },
        },
      },
      {
        -- Debug adapters & configurations
        'mfussenegger/nvim-dap',
        opts = function()
          local dap = require('dap')
          if not dap.adapters['netcoredbg'] then
            require('dap').adapters['netcoredbg'] = {
              type = 'executable',
              command = vim.fn.exepath('netcoredbg'),
              args = { '--interpreter=vscode' },
              options = {
                detached = false,
              },
            }
          end
          for _, filetype in ipairs(language.filetypes) do
            if not dap.configurations[filetype] then
              dap.configurations[filetype] = {
                {
                  type = 'netcoredbg',
                  name = 'Launch file',
                  request = 'launch',
                  ---@diagnostic disable-next-line: redundant-parameter
                  program = function()
                    return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/', 'file')
                  end,
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
          'Issafalcon/neotest-dotnet',
          ft = language.filetypes,
        },
        opts = {
          adapters = {
            ['neotest-dotnet'] = {
              dap = { justMyCode = false },
            },
          },
        },
      },
    }
  or {}
