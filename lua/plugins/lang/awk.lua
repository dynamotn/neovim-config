---@diagnostic disable-next-line: unused-local
local language = require('config.languages').awk
return vim.list_contains(_G.enabled_languages, 'awk')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            awk_ls = {},
          },
        },
      },
    }
  or {}
