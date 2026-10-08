local language = require('config.languages').rust

return vim.list_contains(_G.enabled_languages, 'rust')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            harper_ls = {},
          },
          setup = {
            -- rustaceanvim starts its own client
            rust_analyzer = function() return true end,
          },
        },
      },
      {
        -- Powerful toolbox
        'mrcjkb/rustaceanvim',
        ft = language.filetypes,
        opts = {
          server = {
            on_attach = function(_, bufnr)
              vim.keymap.set(
                'n',
                '<leader>cR',
                function() vim.cmd.RustLsp('codeAction') end,
                { desc = 'Code Action', buffer = bufnr }
              )
              vim.keymap.set(
                'n',
                '<leader>dr',
                function() vim.cmd.RustLsp('debuggables') end,
                { desc = 'Rust Debuggables', buffer = bufnr }
              )
            end,
            default_settings = {
              -- rust-analyzer language server configuration
              ['rust-analyzer'] = {
                cargo = {
                  allFeatures = true,
                  loadOutDirsFromCheck = true,
                  buildScripts = {
                    enable = true,
                  },
                },
                -- Run the check on save; rustaceanvim makes it `clippy` when
                -- `cargo-clippy` is on `$PATH`
                checkOnSave = true,
                -- rust-analyzer's own diagnostics, on top of the check's
                diagnostics = {
                  enable = true,
                },
                procMacro = {
                  enable = true,
                },
                files = {
                  exclude = {
                    '.direnv',
                    '.git',
                    '.github',
                    '.gitlab',
                    'bin',
                    'node_modules',
                    'target',
                    'venv',
                    '.venv',
                  },
                  -- Avoid Roots Scanned hanging, see https://github.com/rust-lang/rust-analyzer/issues/12613#issuecomment-2096386344
                  watcher = 'client',
                },
              },
            },
          },
        },
        -- No `dap.adapter`: rustaceanvim finds Mason's codelldb and its
        -- liblldb itself as a session starts, where a path read here was
        -- empty for good whenever codelldb was installed after startup
        config = function(_, opts)
          vim.g.rustaceanvim =
            vim.tbl_deep_extend('keep', vim.g.rustaceanvim or {}, opts or {})
          if vim.fn.executable('rust-analyzer') == 0 then
            LazyVim.error(
              '**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/',
              { title = 'rustaceanvim' }
            )
          end
        end,
      },
      {
        -- Test adapter
        'nvim-neotest/neotest',
        opts = {
          adapters = {
            ['rustaceanvim.neotest'] = {},
          },
        },
      },
    }
  or {}
