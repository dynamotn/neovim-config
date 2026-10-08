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
--- over whatever the parser returned. It keeps the upstream definition's
--- shape: a table stays a table, so a language's `opts` can still set `args`
--- on it, and a function is still only called at lint time. A mapper that
--- finds nothing hands the diagnostic back untouched: a tool that changes the
--- shape of its output loses the ignore comment again and nothing else.

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
---
--- The wrapping happens the first time a linter is looked up, not here.
--- Indexing `lint.linters` requires the upstream module, and some of those do
--- real work on load: `golangcilint` shells out to `golangci-lint version` and
--- `go env GOMOD`, which cost every buffer of every filetype well over 100ms
--- at startup. Wrapping in a function instead would defer that too, but would
--- turn a table linter into a function, and the `lint.linters[name].args = ...`
--- a language sets would then index a function. So the lookup itself is
--- taken over: the first access loads, wraps and stores the linter, and every
--- later one finds the wrapped table in place.
M.setup = function()
  local lint = require('lint')
  local wrap = require('lint.util').wrap
  local meta = getmetatable(lint.linters)
  if meta.dy_lint_code then return end
  meta.dy_lint_code = true

  -- One set before this ran is already loaded, so there is nothing to defer.
  for name, mapper in pairs(M.mappers) do
    local linter = rawget(lint.linters, name)
    if linter then lint.linters[name] = wrap(linter, mapper) end
  end

  local index = meta.__index
  meta.__index = function(linters, name)
    local linter = index(linters, name)
    local mapper = M.mappers[name]
    if linter and mapper then
      linter = wrap(linter, mapper)
      rawset(linters, name, linter)
    end
    return linter
  end
end

return M
