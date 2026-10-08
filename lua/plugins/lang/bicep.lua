---@diagnostic disable-next-line: unused-local
local language = require('config.languages').bicep

return vim.list_contains(DyNeo.enabled_languages, 'bicep')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            bicep = {},
          },
        },
      },
    }
  or {}
