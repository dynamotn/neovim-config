--- Put back the rule id that nvim-lint leaves out of a diagnostic
---
--- `nvim-rulebook` builds a tool's ignore comment out of `diagnostic.code`,
--- and a fair number of nvim-lint's parsers never set one. The id is not
--- missing from the tool's output, only from the diagnostic: it is left
--- sitting in the message, or put in `source` where the tool's name belongs.
--- The rulebook entry for such a tool is dead either way -- `markdownlint`,
--- `ansible-lint` and `swiftlint` ship with the plugin and none of the three
--- could ever fire.
---
--- Each linter below is wrapped with nvim-lint's own `util.wrap`, which maps
--- over whatever the parser returned. The wrapper is installed as a function,
--- so the upstream linter is still required at lint time rather than at
--- startup, and a mapper that finds nothing hands the diagnostic back
--- untouched: a tool that changes the shape of its output loses the ignore
--- comment again and nothing else.

local M = {}

--- Read the rule id out of the message
---
--- The first pattern that matches wins, so a tool that spells a plain rule
--- and a rule with a sub-rule differently gets one entry, not two.
---@param patterns string[] Lua patterns, each with the rule id as its capture
---@return fun(diagnostic: vim.Diagnostic): vim.Diagnostic
local function from_message(patterns)
  return function(diagnostic)
    if diagnostic.code then return diagnostic end
    local message = diagnostic.message or ''
    for _, pattern in ipairs(patterns) do
      local code = message:match(pattern)
      if code then
        diagnostic.code = code
        break
      end
    end
    return diagnostic
  end
end

--- Move the rule id out of `source` and put the tool's name there
---
--- A couple of parsers report the rule where the tool belongs, which leaves
--- rulebook with a different `source` for every rule and no code at all.
---@param tool string Name of the tool, as rulebook should key it
---@return fun(diagnostic: vim.Diagnostic): vim.Diagnostic
local function from_source(tool)
  return function(diagnostic)
    if not diagnostic.code and diagnostic.source then
      diagnostic.code = diagnostic.source
    end
    diagnostic.source = tool
    return diagnostic
  end
end

--- One mapper per linter, keyed by its nvim-lint name. The sample above each
--- is the line the pattern was read off.
---@type table<string, fun(diagnostic: vim.Diagnostic): vim.Diagnostic>
M.mappers = {
  -- stdin:3:81 error MD013/line-length Line length [Expected: 80; Actual: 110]
  --
  -- The number, not the alias: rulebook prefixes what it gets with `MD` to
  -- look the alias up for itself.
  ['markdownlint-cli2'] = from_message({ '(MD%d+)/' }),

  -- playbook.yml:4:7: name[casing] All names should start with an uppercase
  -- playbook.yml:7:1: risky-file-permissions File permissions unset or
  --
  -- The rule opens the message, and the second pattern asks for a hyphen in
  -- it rather than taking any first word: a rule id has one or carries a
  -- sub-rule in brackets, and reading the first word of an ordinary sentence
  -- as a rule would put a wrong code on the diagnostic for everyone to see.
  ansible_lint = from_message({
    '^(%l[%w%-_]*%b[])',
    '^(%l[%w_]*%-[%w%-_]*)%s',
  }),

  -- Foo.swift:3:1: warning: Line Length Violation: ... (line_length)
  swiftlint = from_message({ '%((%l[%w_]*)%)%s*$' }),

  -- The parser writes the rule into the message and keeps the link below it:
  --   "t1.tiny" is an invalid value (aws_instance_invalid_type)
  --   Reference: https://github.com/terraform-linters/tflint/...
  tflint = from_message({ '%(([%w_]+)%)\nReference:' }),

  -- `--verbose '%l:%c:%s %m [%p]'` puts the policy last, in brackets, in the
  -- short form `## no critic` takes.
  perlcritic = from_message({ '%[([%w:]+)%]%s*$' }),

  -- Reports the sub-linter -- `errcheck`, `govet` -- where the tool's name
  -- belongs, which is also the word `//nolint:` wants.
  golangcilint = from_source('golangci-lint'),

  -- Same again with buf's rule ids, `FIELD_LOWER_SNAKE_CASE` and the like.
  buf_lint = from_source('buf_lint'),
}

--- Wrap every linter in `M.mappers`
M.setup = function()
  local lint = require('lint')
  local wrap = require('lint.util').wrap
  for name, mapper in pairs(M.mappers) do
    lint.linters[name] = wrap(function()
      local linter = require('lint.linters.' .. name)
      return type(linter) == 'function' and linter() or linter
    end, mapper)
  end
end

return M
