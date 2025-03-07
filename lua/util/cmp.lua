local M = {}

--- Get default sources of each filetypes
M.default_sources = function()
  local success, node = pcall(vim.treesitter.get_node)
  if success and node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
    return M.comment_sources()
  else
    return M.per_filetype_with_predefined_sources({})
  end
end

--- Sources for comment
M.comment_sources = function() return { 'buffer', 'ripgrep', 'dictionary', 'dynamic' } end

--- Sources for all filetypes
M.common_sources = function() return { 'snippets', 'buffer', 'ripgrep', 'calc', 'tmux', 'dynamic', 'dictionary' } end

--- Sources for unique filetype
---@param unique_sources string[] Unique sources
M.per_filetype_sources = function(unique_sources) return vim.list_extend(unique_sources, M.common_sources()) end

--- Sources for unique filetype with predefined sources
---@param unique_sources string[] Unique sources
M.per_filetype_with_predefined_sources = function(unique_sources)
  local result = { 'lsp' }
  vim.list_extend(result, unique_sources)
  vim.list_extend(result, { 'path', 'project_path' })
  return vim.list_extend(result, M.common_sources())
end

return M
