local M = {}

-- Activate tool
M.active_tool = function(name, method, is_external_tool, is_custom_tool, with_config)
  with_config = with_config or {}
  is_external_tool = is_external_tool == nil and true or is_external_tool
  is_custom_tool = is_custom_tool == nil and false or is_custom_tool
  local source
  if is_custom_tool then
    local ok, _ = pcall(require, 'tools.' .. method .. '.' .. name)

    if not ok then
      return
    end
    source = require('tools.' .. method .. '.' .. name).with(with_config)
  else
    source = require('null-ls').builtins[method][name].with(with_config)
  end

  if is_external_tool then
    return vim.fn.executable(name) == 1 and source
  else
    return source
  end
end

return M
