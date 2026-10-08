---@diagnostic disable-next-line: unused-local
local language = require('config.languages').gitrebase
local cmp_util = require('util.cmp')

return vim.list_contains(DyNeo.enabled_languages, 'gitrebase')
    and {
      {
        -- Completion source, on this filetype too. Not a dependency of
        -- blink.cmp, which would load it on the first `InsertEnter` of any
        -- buffer.
        'petertriho/cmp-git',
        ft = language.filetypes,
      },
      {
        -- Completion
        'blink.cmp',
        opts = {
          sources = {
            compat = { 'git' },
            per_filetype = {
              gitrebase = cmp_util.sources('gitrebase'),
            },
          },
        },
      },
    }
  or {}
