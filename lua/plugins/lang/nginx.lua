---@diagnostic disable-next-line: unused-local
local language = require('config.languages').nginx

return vim.list_contains(DyNeo.enabled_languages, 'nginx')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            nginx_language_server = {},
          },
        },
      },
    }
  or {}
