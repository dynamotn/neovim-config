local M = {}

local modules = {
  'comment',
  'completion',
  'snippet',
  'lsp',
  'null_ls',
  'treesitter',
  'typing',
  'refactoring',
  'syntax',
}

for _, module in ipairs(modules) do
  local ok, result = pcall(require, 'plugins.list.editor.' .. module)
  if ok then
    vim.list_extend(M, result)
  end
end

return M
