local M = {}

-- Handle output of ltcc command
M.handle_output = function(params)
  local actions = {}

  for _, m in ipairs(params.output) do
    if
      m.replacements ~= vim.NIL and params.row == m.moreContext.line_number
    then
      local row = m.moreContext.line_number - 1
      local col_beg = m.moreContext.line_offset
      local col_end = m.moreContext.line_offset + m.length

      for _, r in ipairs(m.replacements) do
        if string.find(r.value, 'not shown') == nil then
          table.insert(actions, {
            title = 'Replace with “' .. r.value .. '”',
            action = function()
              vim.api.nvim_buf_set_text(
                params.bufnr,
                row,
                col_beg,
                row,
                col_end,
                { r.value }
              )
            end,
          })
        end
      end
    end
  end

  return actions
end

return M
