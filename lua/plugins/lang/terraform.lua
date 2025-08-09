---@diagnostic disable-next-line: unused-local
local language = require('config.languages').terraform

return vim.list_contains(_G.enabled_languages, 'terraform')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            terraformls = {},
          },
        },
      },
    }
  or {}
