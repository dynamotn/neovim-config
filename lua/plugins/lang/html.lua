local condition = vim.list_contains(DyNeo.enabled_languages, 'html')
  or vim.list_contains(DyNeo.enabled_languages, 'angular')
  or vim.list_contains(DyNeo.enabled_languages, 'rails')
  or vim.list_contains(DyNeo.enabled_languages, 'vue')

return condition
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            tailwindcss = {},
            html = {},
            harper_ls = {},
          },
        },
      },
    }
  or {}
