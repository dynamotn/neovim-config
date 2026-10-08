---@diagnostic disable-next-line: unused-local
local language = require('config.languages').groovy

return vim.list_contains(DyNeo.enabled_languages, 'groovy')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            groovyls = {},
          },
        },
      },
    }
  or {}
