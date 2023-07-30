local M = {}

local modules = {
  'base',
  'colorscheme',
  'status',
  'trouble',
  'highlight',
  'layout',
  'lsp',
  'dap',
  'util',
}

for _, module in ipairs(modules) do
  local ok, result = pcall(require, 'plugins.list.ui.' .. module)
  if ok then
    vim.list_extend(M, result)
  end
end

return M
