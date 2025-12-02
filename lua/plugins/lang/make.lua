---@diagnostic disable-next-line: unused-local
local language = require('config.languages').make

vim.g.make_flavor = 'gnu'

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
