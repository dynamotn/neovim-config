local language = require('config.languages').cpp

return vim.list_contains(_G.enabled_languages, 'cpp')
    and {
      {
        -- Toolbox for clang
        'p00f/clangd_extensions.nvim',
        ft = language.filetypes,
        -- Only the AST, memory usage and symbol info views are its own now:
        -- clangd itself is set up like any other server
        opts = {
          ast = {
            role_icons = {
              type = '',
              declaration = '',
              expression = '',
              specifier = '',
              statement = '',
              ['template argument'] = '',
            },
            kind_icons = {
              Compound = '',
              Recovery = '',
              TranslationUnit = '',
              PackExpansion = '',
              TemplateTypeParm = '',
              TemplateTemplateParm = '',
              TemplateParamObject = '',
            },
          },
        },
      },
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            clangd = {
              keys = {
                {
                  '<leader>ch',
                  '<cmd>ClangdSwitchSourceHeader<cr>',
                  ft = language.filetypes,
                  desc = 'Switch Source/Header (C/C++)',
                },
              },
              root_markers = {
                'compile_commands.json',
                'compile_flags.txt',
                'configure.ac', -- AutoTools
                'Makefile',
                'configure.in',
                'config.h.in',
                'meson.build',
                'meson_options.txt',
                'build.ninja',
                '.git',
              },
              capabilities = {
                offsetEncoding = { 'utf-16' },
              },
              cmd = {
                'clangd',
                '--background-index',
                '--clang-tidy',
                '--header-insertion=iwyu',
                '--completion-style=detailed',
                '--function-arg-placeholders',
                '--fallback-style=llvm',
              },
              init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
              },
            },
            harper_ls = {},
          },
        },
      },
      {
        -- Debug adapters & configurations
        'mfussenegger/nvim-dap',
        optional = true,
        opts = function()
          local dap_util = require('util.dap')
          dap_util.codelldb_adapter()
          for _, lang in ipairs({ 'c', 'cpp' }) do
            require('dap').configurations[lang] =
              dap_util.codelldb_configurations('')
          end
        end,
      },
      {
        -- Test adapter
        'nvim-neotest/neotest',
        dependencies = {
          'alfaix/neotest-gtest',
          ft = language.filetypes,
        },
        -- neotest-gtest compiles a C++ query as it loads, so without the
        -- `cpp` parser -- installed with the first C++ buffer -- its `require`
        -- throws, and takes the setup of every other adapter down with it
        opts = function(_, opts)
          opts.adapters = opts.adapters or {}
          opts.adapters['neotest-gtest'] = vim.treesitter.language.add('cpp')
              and {}
            or false
        end,
      },
    }
  or {}
