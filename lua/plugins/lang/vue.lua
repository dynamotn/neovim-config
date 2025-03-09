local language = require('config.languages').vue
local augend = require('dial.augend')

return vim.list_contains(_G.enabled_languages, 'vue')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            volar = {
              init_options = {
                vue = {
                  hybridMode = true,
                },
              },
            },
            vtsls = {},
          },
        },
      },
      {
        -- Extend LSP config of vtsls by plugin for vue
        'neovim/nvim-lspconfig',
        opts = function(_, opts)
          table.insert(opts.servers.vtsls.filetypes, 'vue')
          LazyVim.extend(
            opts.servers.vtsls,
            'settings.vtsls.tsserver.globalPlugins',
            {
              {
                name = '@vue/typescript-plugin',
                location = function()
                  return LazyVim.get_pkg_path(
                    'vue-language-server',
                    '/node_modules/@vue/language-server'
                  )
                end,
                languages = { 'vue' },
                configNamespace = 'typescript',
                enableForWorkspaceTypeScriptVersions = true,
              },
            }
          )
        end,
      },
      {
        -- Custom dial
        'monaqa/dial.nvim',
        opts = {
          groups = {
            vue = {
              augend.constant.new({ elements = { 'let', 'const' } }),
              augend.hexcolor.new({ case = 'lower' }),
              augend.hexcolor.new({ case = 'upper' }),
            },
          },
        },
      },
    }
  or {}
