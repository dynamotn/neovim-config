---@diagnostic disable-next-line: unused-local
local language = require('config.languages').terraform

return vim.list_contains(DyNeo.enabled_languages, 'terraform')
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
