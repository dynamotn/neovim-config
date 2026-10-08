return vim.list_contains(_G.enabled_languages, 'vue')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            -- Hybrid mode is the only one since vue_ls 3, so it needs no
            -- option: vtsls carries the TypeScript side
            vue_ls = {},
            vtsls = {},
            tailwindcss = {},
            harper_ls = {},
          },
        },
      },
      {
        -- Extend LSP config of vtsls by plugin for Vue
        'neovim/nvim-lspconfig',
        opts = function(_, opts)
          table.insert(opts.servers.vtsls.filetypes, 'vue')
          require('util.plugin').extend(
            opts.servers.vtsls,
            'settings.vtsls.tsserver.globalPlugins',
            {
              {
                name = '@vue/typescript-plugin',
                -- A path, not a function: settings are sent to the server
                -- as JSON, and a function cannot be encoded. The package is
                -- only installed with the first Vue file, so a missing one
                -- is expected and not warned about.
                location = require('util.plugin').get_pkg_path(
                  'vue-language-server',
                  '/node_modules/@vue/language-server',
                  { warn = false }
                ),
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
