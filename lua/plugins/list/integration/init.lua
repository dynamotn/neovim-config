local M = {}

local modules = {
  'fuzzy',
  '3rd',
}

for _, module in ipairs(modules) do
  local ok, result = pcall(require, 'plugins.list.integration.' .. module)
  if ok then
    vim.list_extend(M, result)
  end
end

return M
