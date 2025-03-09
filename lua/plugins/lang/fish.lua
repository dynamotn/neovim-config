local language = require('config.languages').fish
local cmp_util = require('util.cmp')

return vim.list_contains(_G.enabled_languages, 'fish')
    and {
      {
        -- Completion
        'blink.cmp',
        dependencies = {
          'mtoohey31/cmp-fish',
          ft = language.filetypes,
          init = function()
            _G.completion_sources =
              vim.tbl_extend('force', _G.completion_sources, {
                fish = '「FISH」',
              })
          end,
        },
        opts = {
          sources = {
            compat = { 'fish' },
            per_filetype = {
              fish = cmp_util.sources('fish'),
            },
          },
        },
      },
    }
  or {}
