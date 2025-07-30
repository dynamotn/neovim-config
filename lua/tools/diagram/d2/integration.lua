local renderer = require('tools.diagram.d2.renderer')
local ts_query = require('vim.treesitter.query')
local query

---@class Integration
local M = {
  id = 'd2',
  filetypes = { 'd2' },
  renderers = {
    renderer,
  },
}

local function get_max_end_col_of_descendants(root_node)
  if not root_node then return 0 end

  return max_end_col
end

M.query_buffer_diagrams = function(bufnr)
  if not query then query = ts_query.parse('d2', '(source_file)') end
  local buf = bufnr or vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(buf, 'd2')
  if not parser then
    vim.notify(
      'No D2 parser found for the current buffer',
      vim.log.levels.ERROR
    )
    return {}
  end
  parser:parse(true)

  local root = parser:parse()[1]:root()

  local start_row, _ = root:start()
  local max_end_col = 0
  local current_node = root

  local stack = { current_node }

  while #stack > 0 do
    current_node = table.remove(stack)

    local _, end_col = current_node:end_()
    if end_col > max_end_col then max_end_col = end_col end

    for i = current_node:child_count() - 1, 0, -1 do
      local child = current_node:child(i)
      if child then table.insert(stack, child) end
    end
  end

  local size = require('image.utils').term.get_size()

  local diagrams = {
    {
      bufnr = bufnr,
      renderer_id = 'd2_file',
      range = {
        start_row = start_row,
        start_col = max_end_col + 7,
        end_row = size.screen_rows,
        end_col = size.screen_cols,
      },
      source = vim.api.nvim_buf_get_name(bufnr),
      with_virtual_padding = false,
      inline = false,
    },
  }

  return diagrams
end

return M
