local language = require('config.languages').rails

return vim.list_contains(_G.enabled_languages, 'rails')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            ruby_lsp = {},
            tailwindcss = {},
            harper_ls = {},
          },
        },
      },
      {
        -- Extended snippets for Rails
        'friendly-snippets',
        config = function()
          require('luasnip').filetype_extend('ruby', { 'rails' })
        end,
      },
    }
  or {}
