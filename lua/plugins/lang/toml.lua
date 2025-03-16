local language = require('config.languages').toml

return vim.list_contains(_G.enabled_languages, 'toml')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            harper_ls = {},
          },
        },
      },
      {
        -- Mise injection
        'nvim-treesitter/nvim-treesitter',
        opts = {
          custom_predicates = {
            ['is-mise?'] = '.*mise.*%.toml$',
          },
        },
      },
      {
        -- Work with crates of Rust
        'Saecki/crates.nvim',
        event = { 'BufRead Cargo.toml' },
        opts = {
          completion = {
            crates = {
              enabled = true,
            },
          },
          lsp = {
            enabled = true,
            actions = true,
            completion = true,
            hover = true,
          },
        },
      },
    }
  or {}
