--- nvim-lint linter for `kube-linter`, best practices of Kubernetes manifests.
---
--- kube-linter reports an object, not a line: each report lands on the line
--- that names the object (`name: <its name>`) in the buffer, else on the
--- first line. A `.kube-linter.yaml` in the working directory is read as
--- usual.

local M = {}

--- The first line of `lines` that names `name`, 0-based
---@param lines string[]
---@param name? string
---@return integer
function M.line_of(lines, name)
  if type(name) ~= 'string' or name == '' then return 0 end
  for index, line in ipairs(lines) do
    -- `name: x`, or `- name: x` as the first key of a list item
    local value = line:match('^%s*%-?%s*name:%s*(.-)%s*$')
    if value then
      value = value:gsub('^["\']', ''):gsub('["\']$', '')
      if value == name then return index - 1 end
    end
  end
  return 0
end

--- The diagnostics of a `kube-linter lint --format json` report
---@param output string
---@param bufnr? integer
---@return vim.Diagnostic[]
function M.parse(output, bufnr)
  if output == nil or output == '' then return {} end
  local ok, report =
    pcall(vim.json.decode, output, { luanil = { object = true, array = true } })
  if not ok or type(report) ~= 'table' then return {} end
  local lines = bufnr and vim.api.nvim_buf_get_lines(bufnr, 0, -1, false) or {}
  local diagnostics = {}
  for _, item in
    ipairs(type(report.Reports) == 'table' and report.Reports or {})
  do
    local name = vim.tbl_get(item, 'Object', 'K8sObject', 'Name')
    local lnum = M.line_of(lines, name)
    local message = vim.tbl_get(item, 'Diagnostic', 'Message')
      or item.Check
      or 'kube-linter finding'
    if type(item.Remediation) == 'string' and item.Remediation ~= '' then
      message = message .. '\n' .. item.Remediation
    end
    table.insert(diagnostics, {
      lnum = lnum,
      col = 0,
      end_lnum = lnum,
      severity = vim.diagnostic.severity.WARN,
      message = message,
      code = item.Check,
      source = 'kube-linter',
      user_data = { lsp = { code = item.Check } },
    })
  end
  return diagnostics
end

--- Lint only Kubernetes manifests
---@return boolean
function M.condition() return require('tools.kube').is_kube(0) end

M.linter = {
  name = 'kube_linter',
  cmd = 'kube-linter',
  stdin = false,
  args = { 'lint', '--format', 'json' },
  stream = 'stdout',
  -- Findings are a non-zero exit
  ignore_exitcode = true,
  condition = M.condition,
  parser = M.parse,
}

return setmetatable(M.linter, { __index = M })
