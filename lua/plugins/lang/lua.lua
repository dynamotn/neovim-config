local language = require('config.languages').lua

return vim.list_contains(_G.enabled_languages, 'lua')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            lua_ls = {
              settings = {
                Lua = {
                  workspace = {
                    checkThirdParty = false,
                  },
                  codeLens = {
                    enable = true,
                  },
                  completion = {
                    callSnippet = 'Replace',
                  },
                  doc = {
                    privateName = { '^_' },
                  },
                  hint = {
                    enable = true,
                    setType = false,
                    paramType = true,
                    paramName = 'Disable',
                    semicolon = 'Disable',
                    arrayIndex = 'Disable',
                  },
                },
              },
            },
          },
        },
      },
      {
        -- Nvim LSP
        'lazydev.nvim',
        ft = language.filetypes,
        init = function()
          _G.completion_sources = vim.tbl_extend('force', _G.completion_sources, {
            Lazydev = '「VIM」',
          })
        end,
      },
      {
        -- Debug adapters & configurations
        'jbyuki/one-small-step-for-vimkind',
        ft = language.filetypes,
        keys = {
          {
            '<leader>dn',
            function()
              require('osv').launch({ port = 8086 })
            end,
            desc = 'Launch debug Neovim',
          },
        },
        config = function()
          local dap = require('dap')
          dap.adapters.nlua = function(callback, conf)
            local adapter = {
              type = 'server',
              host = conf.host or '127.0.0.1',
              port = conf.port or 8086,
            }
            if conf.start_neovim then
              local dap_run = dap.run
              dap.run = function(c)
                adapter.port = c.port
                adapter.host = c.host
              end
              require('osv').run_this()
              dap.run = dap_run
            end
            callback(adapter)
          end
          dap.configurations.lua = {
            {
              type = 'nlua',
              request = 'attach',
              name = 'Run this file',
              start_neovim = {},
            },
            {
              type = 'nlua',
              request = 'attach',
              name = 'Attach to running Neovim instance (port = 8086)',
              port = 8086,
            },
          }
        end,
      },
      {
        -- Custom dial
        'monaqa/dial.nvim',
        opts = {
          groups = {
            lua = language.dial(),
          },
        },
      },
    }
  or {}
