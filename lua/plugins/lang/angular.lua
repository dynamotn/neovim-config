local language = require('config.languages').angular

return vim.list_contains(DyNeo.enabled_languages, 'angular')
    and {
      {
        -- Extended snippets for angular. From LuaSnip's `opts`, which merge:
        -- a `config` on friendly-snippets would replace the one that loads it
        'L3MON4D3/LuaSnip',
        opts = function()
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
              Snacks.util.lsp.on({ name = 'angularls' }, function(_, client)
                --HACK: disable angular renaming capability due to duplicate rename popping up
                client.server_capabilities.renameProvider = false
              end)
            end,
          },
        },
      },
      {
        -- Extend LSP config of tailwindcss by plugin for Angular
        'neovim/nvim-lspconfig',
        opts = function(_, opts)
          require('util.plugin').extend(
            opts.servers.tailwindcss,
            'filetypes',
            language.filetypes
          )
        end,
      },
    }
  or {}
