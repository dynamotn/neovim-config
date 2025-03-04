local language = require('config.languages').htmlangular

return vim.list_contains(_G.enabled_languages, 'htmlangular')
    and {
      {
        -- Extended snippets for angular
        'friendly-snippets',
        config = function()
          require('luasnip').filetype_extend('htmlangular', { 'angular' })
          require('luasnip').filetype_extend('typescript', { 'angular' })
        end,
      },
      {
        -- Config for LSP
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            angularls = {},
          },
          setup = {
            angularls = function()
              LazyVim.lsp.on_attach(function(client)
                --HACK: disable angular renaming capability due to duplicate rename popping up
                client.server_capabilities.renameProvider = false
              end, 'angularls')
            end,
          },
        },
      },
    }
  or {}
