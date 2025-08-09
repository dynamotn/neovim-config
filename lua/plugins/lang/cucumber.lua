---@diagnostic disable-next-line: unused-local
local language = require('config.languages').cucumber
return vim.list_contains(_G.enabled_languages, 'cucumber')
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
