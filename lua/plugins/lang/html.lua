local language = require('config.languages').html
local condition = vim.list_contains(_G.enabled_languages, 'html')
  or vim.list_contains(_G.enabled_languages, 'angular')
  or vim.list_contains(_G.enabled_languages, 'rail')
  or vim.list_contains(_G.enabled_languages, 'vue')

return condition
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            tailwindcss = {},
            html = {},
            harper_ls = {},
          },
        },
      },
      {
        -- Extend LSP config for HTML
        'neovim/nvim-lspconfig',
        opts = function(_, opts)
          LazyVim.extend(
            opts.servers.harper_ls,
            'filetypes',
            language.filetypes
          )
        end,
      },
    }
  or {}
