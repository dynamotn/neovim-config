local language = require('config.languages').vue

return vim.list_contains(_G.enabled_languages, 'vue')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            vue_ls = {
              init_options = {
                vue = {
                  hybridMode = true,
                },
              },
            },
            vtsls = {},
            tailwindcss = {},
            harper_ls = {},
          },
        },
      },
      {
        -- Extend LSP config for HTML
        'neovim/nvim-lspconfig',
        opts = function(_, opts)
          LazyVim.extend(
            opts.servers.harper_ls,
            'filetypes',
            language.filetypes
          )
        end,
      },
      {
        -- Extend LSP config of vtsls by plugin for Vue
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
    }
  or {}
