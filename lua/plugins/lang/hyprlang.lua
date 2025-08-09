---@diagnostic disable-next-line: unused-local
local language = require('config.languages').hyprlang

return vim.list_contains(_G.enabled_languages, 'hyprlang')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            hyprls = {},
          },
        },
      },
    }
  or {}
