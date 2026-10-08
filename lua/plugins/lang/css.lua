local language = require('config.languages').css

return vim.list_contains(DyNeo.enabled_languages, 'css')
    and {
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
          require('util.plugin').extend(
            opts.servers.tailwindcss,
            'filetypes',
            language.filetypes
          )
        end,
      },
    }
  or {}
