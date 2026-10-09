--- The checks text that is no buffer passes before it goes to an AI
---
--- A diff, a CI log: nothing `util.sensitive` has looked at, since it never
--- sat in a buffer. It is let through once no path it names is sensitive and
--- neither `config.sensitive`'s patterns nor `betterleaks` find a secret in
--- it. A check that cannot run refuses, as a finding would.
local M = {}

--- Milliseconds `betterleaks` may take
M.TIMEOUT = 30 * 1000

--- What keeps `text` from going out, if anything: one of `paths` that is
--- sensitive, or a line with the shape of a credential
---@param root string What `paths` are relative to
---@param paths string[]
---@param text string
---@return string? reason
function M.refusal(root, paths, text)
  local sensitive = require('util.sensitive')
  for _, path in ipairs(paths) do
    if sensitive.is_sensitive_path(vim.fs.joinpath(root, path)) then
      return ('%s is kept from AI'):format(path)
    end
  end
  -- Every line, removed ones too: a secret a commit takes out is still in
  -- the text that would be sent
  for line in text:gmatch('[^\n]+') do
    local rule = sensitive.secret_format(line)
    if rule then return ('the text holds a %s'):format(rule) end
  end
end

--- Run `betterleaks` over `text`, with live validation off so nothing of it
--- reaches a provider, and hand `on_done` why it must not go out, or nil
---@param cwd string Where its configuration is looked for
---@param text string
---@param on_done fun(reason?: string)
function M.scan(cwd, text, on_done)
  local system = require('util.system')
  system.run({
    'betterleaks',
    'stdin',
    '--report-format=json',
    '--report-path=-',
    '--exit-code=0',
    '--no-banner',
    '--log-level=error',
    '--validation=false',
    '--redact',
  }, { cwd = cwd, stdin = text, timeout = M.TIMEOUT }, function(result)
    if result.code ~= 0 or result.cut then
      return on_done(
        'betterleaks could not check it: '
          .. system.failure(result, 'betterleaks')
      )
    end
    local ok, findings = pcall(vim.json.decode, result.stdout)
    if not ok or type(findings) ~= 'table' then
      return on_done('betterleaks gave a report that does not read')
    end
    if #findings == 0 then return on_done(nil) end
    local rules = {}
    for _, finding in ipairs(findings) do
      rules[finding.RuleID or 'finding'] = true
    end
    local names = vim.tbl_keys(rules)
    table.sort(names)
    on_done(('betterleaks found %s in it'):format(table.concat(names, ', ')))
  end)
end

--- Both checks, the cheap one first
---@param root string
---@param paths string[]
---@param text string
---@param on_done fun(reason?: string)
function M.text(root, paths, text, on_done)
  local reason = M.refusal(root, paths, text)
  if reason then return on_done(reason) end
  M.scan(root, text, on_done)
end

return M
