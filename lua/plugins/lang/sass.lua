---@diagnostic disable-next-line: unused-local
local language = require('config.languages').sass

return vim.list_contains(_G.enabled_languages, 'sass')
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
    }
  or {}
