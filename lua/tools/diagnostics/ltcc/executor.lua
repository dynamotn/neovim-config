local h = require('null-ls.helpers')
local M = {}

-- Handle output of ltcc command
M.handle_output = function(params)
  local file = params.output
  if file and file then
    local parser = h.diagnostics.from_json({
      severities = {
        ERROR = h.diagnostics.severities.error,
      },
    })

    local offenses = {}

    for _, m in ipairs(file) do
      local tip = table.concat(vim.tbl_map(function(r) return '“' .. r.value .. '”' end, m.replacements), ', ')

      table.insert(offenses, {
        message = m.message .. ' Try: ' .. tip,
        ruleId = m.rule.id,
        level = 'ERROR',
        line = m.moreContext.line_number,
        column = m.moreContext.line_offset + 1,
        endLine = m.moreContext.line_number,
        endColumn = m.moreContext.line_offset + m.length + 1,
      })
    end

    return parser({ output = offenses })
  end

  return {}
end

return M
