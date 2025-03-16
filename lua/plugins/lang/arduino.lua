local language = require('config.languages').arduino
return vim.list_contains(_G.enabled_languages, 'arduino')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            arduino_language_server = {},
          },
        },
      },
      {
        -- Extend LSP config of harper_ls by plugin for Arduino
        'neovim/nvim-lspconfig',
        opts = function(_, opts)
          LazyVim.extend(
            opts.servers.harper_ls,
            'filetypes',
            language.filetypes
          )
        end,
      },
    }
  or {}
