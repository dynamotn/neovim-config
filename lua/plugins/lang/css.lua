local language = require('config.languages').css

return vim.list_contains(_G.enabled_languages, 'css')
    and {
      {
        -- Custom dial
        'monaqa/dial.nvim',
        opts = {
          groups = {
            css = language.dial(),
          },
        },
      },
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            tailwindcss = {},
          },
        },
      },
      {
        -- Extend LSP config
        'neovim/nvim-lspconfig',
        opts = function(_, opts)
          LazyVim.extend(
            opts.servers.tailwindcss,
            'filetypes',
            language.filetypes
          )
        end,
      },
    }
  or {}
