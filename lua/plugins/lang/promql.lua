---@diagnostic disable-next-line: unused-local
local language = require('config.languages').promql

return vim.list_contains(DyNeo.enabled_languages, 'promql')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            promqlls = {},
          },
        },
      },
    }
  or {}
