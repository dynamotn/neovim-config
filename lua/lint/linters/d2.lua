--- nvim-lint linter for `d2 validate`, which compiles a diagram without
--- rendering it and reports what would stop it from compiling.
---
--- The buffer is piped in on standard input (`-`), so a diagram is checked
--- while it is being written. Each error comes on its own line of stderr, and
--- the first one carries the name of the Go function that raised it:
---
---   err: github.com/d2lang/d2/d2cli.validateCmd: 5:1: connection missing destination
---   err: 5:5: unexpected text after map key
---
--- Drop this file on the runtimepath as `lua/lint/linters/d2.lua` and
--- nvim-lint picks it up by name:
---
---   require('lint').linters_by_ft.d2 = { 'd2' }

return {
  cmd = 'd2',
  stdin = true,
  args = { 'validate', '-' },
  stream = 'stderr',
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(
    '^err: .-(%d+):(%d+): (.+)$',
    { 'lnum', 'col', 'message' },
    nil,
    { severity = vim.diagnostic.severity.ERROR, source = 'd2' }
  ),
}
