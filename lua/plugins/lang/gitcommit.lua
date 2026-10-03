local language = require('config.languages').gitcommit
local cmp_util = require('util.cmp')

return vim.list_contains(_G.enabled_languages, 'gitcommit')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          harper_ls = {},
        },
      },
      {
        -- Completion source. Its own spec rather than a dependency of
        -- blink.cmp, which would load it on the first `InsertEnter` of any
        -- buffer.
        'petertriho/cmp-git',
        ft = language.filetypes,
        init = function()
          _G.completion_sources =
            vim.tbl_extend('force', _G.completion_sources, {
              git = '「GIT」',
            })
        end,
      },
      {
        -- Completion
        'blink.cmp',
        opts = {
          sources = {
            compat = { 'git' },
            per_filetype = {
              gitcommit = cmp_util.sources('gitcommit'),
            },
          },
        },
      },
    }
  or {}
