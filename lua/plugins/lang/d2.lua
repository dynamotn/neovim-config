local language = require('config.languages').d2
local condition = vim.list_contains(_G.enabled_languages, 'd2')

return condition
  and {
    'mfussenegger/nvim-lint',
    opts = function()
      local lint = require('lint')

      lint.linters.d2 = {
        name = 'd2',
        cmd = 'd2',
        stream = 'stderr',
        ignore_exitcode = true,
        parser = require('lint.parser').from_pattern(
          [[:%s*(%d+):(%d+):%s*(.+)]],
          { 'lnum', 'col', 'message' },
          nil,
          {
            source = 'd2',
            severity = vim.diagnostic.severity.ERROR,
          }
        ),
      }

      lint.linters_by_ft.d2 = {
        'd2',
      }
    end,
  }
