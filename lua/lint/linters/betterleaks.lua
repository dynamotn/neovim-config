--- nvim-lint linter for `betterleaks`, the successor of `gitleaks`.
---
--- The buffer is piped in on standard input, so a secret is flagged while it
--- is being typed rather than once it is already on disk. Two of its defaults
--- are turned off on purpose:
---
--- - `--validation` sends every finding to the live API it belongs to, to
---   check whether the key still works. A secret must never leave the
---   machine, so it stays off.
--- - Findings carry the secret and the line around it; `--redact` blanks both
---   out, and only the rule is reported anyway.
---
--- It runs from the root of the buffer's project, which is where it looks for
--- `.betterleaks.toml`/`.gitleaks.toml` and their ignore files.
---
--- Drop this file on the runtimepath as `lua/lint/linters/betterleaks.lua` and
--- nvim-lint picks it up by name:
---
---   require('lint').linters_by_ft['*'] = { 'betterleaks' }

--- Turn one finding into a diagnostic. Lines and columns are 1-based, and the
--- end column is the last character of the match.
---@param finding table One entry of the report
---@param bufnr integer
---@return vim.Diagnostic
local function to_diagnostic(finding, bufnr)
  return {
    bufnr = bufnr,
    lnum = finding.StartLine - 1,
    end_lnum = finding.EndLine - 1,
    col = finding.StartColumn - 1,
    end_col = finding.EndColumn,
    severity = vim.diagnostic.severity.WARN,
    source = 'betterleaks',
    code = finding.RuleID,
    message = finding.Description,
  }
end

return function()
  local name = vim.api.nvim_buf_get_name(0)
  return {
    cmd = 'betterleaks',
    stdin = true,
    args = {
      'stdin',
      '--report-format=json',
      '--report-path=-',
      '--exit-code=0',
      '--no-banner',
      '--log-level=error',
      '--validation=false',
      '--redact',
    },
    cwd = name ~= '' and vim.fs.root(0, { '.git' }) or nil,
    stream = 'stdout',
    ignore_exitcode = false,
    parser = function(output, bufnr)
      local ok, findings = pcall(vim.json.decode, output)
      if not ok or type(findings) ~= 'table' then return {} end
      return vim.tbl_map(
        function(finding) return to_diagnostic(finding, bufnr) end,
        findings
      )
    end,
  }
end
