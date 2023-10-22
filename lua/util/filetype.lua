local M = {}

-- Detect Go template files
M.detect_gotemplate = function(bufnr)
  local content = function()
    local content = vim.api.nvim_buf_get_lines(bufnr, 0, vim.api.nvim_buf_line_count(0), false)
    return table.concat(content, '\n')
  end
  if content():match('{{.+}}') then
    return 'gotmpl'
  end
end

return M
