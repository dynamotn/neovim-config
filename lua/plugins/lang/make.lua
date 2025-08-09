---@diagnostic disable-next-line: unused-local
local language = require('config.languages').make

return vim.list_contains(_G.enabled_languages, 'make')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            autotools_ls = {},
          },
        },
      },
    }
  or {}
