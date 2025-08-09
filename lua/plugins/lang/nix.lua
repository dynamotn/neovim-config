---@diagnostic disable-next-line: unused-local
local language = require('config.languages').nix

return vim.list_contains(_G.enabled_languages, 'nix')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            nil_ls = {},
            harper_ls = {},
          },
        },
      },
    }
  or {}
