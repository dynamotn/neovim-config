---@diagnostic disable-next-line: unused-local
local language = require('config.languages').systemd

return vim.list_contains(DyNeo.enabled_languages, 'systemd')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            systemd_lsp = {},
          },
        },
      },
    }
  or {}
