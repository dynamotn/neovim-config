local M = {}

local modules = {
  'base',
  'ui',
  'navigation',
  'project',
  'editor',
  'executor',
  'integration',
  'util',
}

for _, module in ipairs(modules) do
  local ok, result = pcall(require, 'plugins.list.' .. module)
  if ok then
    vim.list_extend(M, result)
  end
end

return M
