local language = require('config.languages').angular

return vim.list_contains(_G.enabled_languages, 'angular')
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
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            angularls = {},
            tailwindcss = {},
            harper_ls = {},
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
      {
        -- Extend LSP config of harper_ls by plugin for Angular
        'neovim/nvim-lspconfig',
        opts = function(_, opts)
          LazyVim.extend(
            opts.servers.harper_ls,
            'filetypes',
            language.filetypes
          )
          LazyVim.extend(
            opts.servers.tailwindcss,
            'filetypes',
            language.filetypes
          )
        end,
      },
    }
  or {}
