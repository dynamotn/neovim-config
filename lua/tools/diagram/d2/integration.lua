local renderer = require('tools.diagram.d2.renderer')

---@class Integration
local M = {
  id = 'd2',
  filetypes = { 'd2' },
  renderers = {
    renderer,
  },
}

M.query_buffer_diagrams = function(bufnr)
  local diagrams = {}
  ---@type { start_row: number, start_col: number, end_row: number, end_col: number }
  local current_range = {
    start_row = 0,
    start_col = 0,
    end_row = 30,
    end_col = 80,
  }
  table.insert(diagrams, {
    bufnr = bufnr,
    renderer_id = 'd2_file',
    range = current_range,
    source = vim.api.nvim_buf_get_name(bufnr),
  })

  return diagrams
end

return M
