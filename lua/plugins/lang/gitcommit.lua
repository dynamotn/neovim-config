local language = require('config.languages').gitcommit
local cmp_util = require('util.cmp')

return vim.list_contains(_G.enabled_languages, 'gitcommit')
    and {
      {
        -- Completion
        'blink.cmp',
        dependencies = {
          'petertriho/cmp-git',
          ft = language.filetypes,
          init = function()
            _G.completion_sources = vim.tbl_extend('force', _G.completion_sources, {
              git = '「GIT」',
            })
          end,
        },
        opts = {
          sources = {
            compat = { 'git' },
            per_filetype = {
              gitcommit = cmp_util.per_filetype_sources({ 'git' }),
            },
          },
        },
      },
    }
  or {}
