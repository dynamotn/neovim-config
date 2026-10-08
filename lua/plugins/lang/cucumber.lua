---@diagnostic disable-next-line: unused-local
local language = require('config.languages').cucumber
return vim.list_contains(DyNeo.enabled_languages, 'cucumber')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            cucumber_language_server = {},
          },
        },
      },
    }
  or {}
