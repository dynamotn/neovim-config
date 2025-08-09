---@diagnostic disable-next-line: unused-local
local language = require('config.languages').terragrunt

return vim.list_contains(_G.enabled_languages, 'terragrunt')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            terraformls = {},
          },
        },
      },
    }
  or {}
