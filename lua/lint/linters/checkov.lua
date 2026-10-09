--- nvim-lint linter for `checkov`, policy checks of infrastructure code.
---
--- Runs on the file as saved (`-f`), one framework or several: the report is
--- an object for one and a list of objects for more. Each failed check lands
--- on the first line of the block it is about. `--skip-download` keeps checkov
--- from fetching anything from its platform; it runs on its own checks only.
---
--- Kubernetes YAML is only handed over when it is a manifest, see
--- `tools.kube.is_kube`: every other YAML file would be read for nothing.

local M = {}

local severities = {
  CRITICAL = vim.diagnostic.severity.ERROR,
  HIGH = vim.diagnostic.severity.ERROR,
  MEDIUM = vim.diagnostic.severity.WARN,
  LOW = vim.diagnostic.severity.INFO,
  INFO = vim.diagnostic.severity.HINT,
}

--- The diagnostics of a checkov report
---@param output string
---@return vim.Diagnostic[]
function M.parse(output)
  if output == nil or output == '' then return {} end
  local ok, report =
    pcall(vim.json.decode, output, { luanil = { object = true, array = true } })
  if not ok or type(report) ~= 'table' then return {} end
  -- One framework prints an object, several a list of them
  if not vim.islist(report) then report = { report } end
  local diagnostics = {}
  for _, framework in ipairs(report) do
    local failed = type(framework) == 'table'
        and vim.tbl_get(framework, 'results', 'failed_checks')
      or {}
    for _, check in ipairs(failed) do
      local range = type(check.file_line_range) == 'table'
          and check.file_line_range
        or {}
      local first = math.max((tonumber(range[1]) or 1) - 1, 0)
      local message = check.check_name or check.check_id or 'failed check'
      if type(check.guideline) == 'string' and check.guideline ~= '' then
        message = message .. ' (' .. check.guideline .. ')'
      end
      table.insert(diagnostics, {
        lnum = first,
        col = 0,
        end_lnum = first,
        severity = severities[check.severity] or vim.diagnostic.severity.WARN,
        message = message,
        code = check.check_id,
        source = 'checkov',
        user_data = { lsp = { code = check.check_id } },
      })
    end
  end
  return diagnostics
end

--- Lint YAML only when it is a Kubernetes manifest
---@return boolean
function M.condition()
  local ft = vim.bo.filetype
  if ft ~= 'yaml' and not ft:match('^yaml%.') then return true end
  return require('tools.kube').is_kube(0)
end

M.linter = {
  name = 'checkov',
  cmd = 'checkov',
  stdin = false,
  -- `-f` is last, so nvim-lint appends the file right after it
  args = { '--quiet', '--compact', '--skip-download', '-o', 'json', '-f' },
  stream = 'stdout',
  -- A failed check is a non-zero exit
  ignore_exitcode = true,
  condition = M.condition,
  parser = M.parse,
}

-- nvim-lint takes the module as the linter; the functions above ride along
-- for the specs
return setmetatable(M.linter, { __index = M })
