local M = {}

-- Check if plugin is declared in spec
---@param plugin string
M.has_plugin = function(plugin)
  local config = require('lazy.core.config')
  return vim.tbl_contains(config.spec.plugins, plugin)
end

return M
