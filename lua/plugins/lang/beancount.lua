---@diagnostic disable-next-line: unused-local
local language = require('config.languages').beancount

return vim.list_contains(_G.enabled_languages, 'beancount')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            beancount = {},
          },
        },
      },
    }
  or {}
