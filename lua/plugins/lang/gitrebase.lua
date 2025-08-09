---@diagnostic disable-next-line: unused-local
local language = require('config.languages').gitrebase
local cmp_util = require('util.cmp')

return vim.list_contains(_G.enabled_languages, 'gitrebase')
    and {
      {
        -- Completion
        'blink.cmp',
        dependencies = { 'cmp-git' },
        opts = {
          sources = {
            compat = { 'git' },
            per_filetype = {
              gitrebase = cmp_util.sources('git'),
            },
          },
        },
      },
    }
  or {}
