local language = require('config.languages').lua
local cmp_util = require('util.cmp')

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
                    checkThirdParty = true,
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
            harper_ls = {},
          },
        },
      },
      {
        -- Nvim LSP
        'lazydev.nvim',
        ft = language.filetypes,
        init = function()
          _G.completion_sources =
            vim.tbl_extend('force', _G.completion_sources, {
              lazydev = '「VIM」',
            })
        end,
        opts = {
          library = {
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            { path = 'LazyVim', words = { 'LazyVim' } },
            { path = 'snacks.nvim', words = { 'Snacks' } },
            { path = 'lazy.nvim', words = { 'LazyVim' } },
            { path = 'dial.nvim' },
            { path = 'nvim-autopairs' },
            { path = 'nvim-treesitter' },
            { path = 'neoconf' },
          },
        },
      },
      {
        -- Debug adapters & configurations
        'jbyuki/one-small-step-for-vimkind',
        ft = language.filetypes,
        keys = {
          {
            '<leader>dn',
            function() require('osv').launch({ port = 8086 }) end,
            ft = language.filetypes,
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
              ---@diagnostic disable-next-line: duplicate-set-field
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
        -- Completion for Nvim LSP
        'blink.cmp',
        opts = {
          sources = {
            per_filetype = {
              lua = cmp_util.sources('lazydev'),
            },
            providers = {
              lazydev = {
                name = 'lazydev',
                module = 'lazydev.integrations.blink',
                score_offset = 100,
              },
            },
          },
        },
      },
    }
  or {}
