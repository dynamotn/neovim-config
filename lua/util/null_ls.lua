local M = {}

-- Activate tool
M.active_tool = function(args)
  local with_config = args.with_config or {}
  local is_external_tool = args.is_external_tool == nil and true or args.is_external_tool
  local is_custom_tool = args.is_custom_tool == nil and false or args.is_custom_tool
  local lib_name = args.lib_name == nil and nil or args.lib_name
  local source
  if is_custom_tool then
    local ok, _ = pcall(require, 'tools.' .. args.method .. '.' .. args.name)

    if not ok then
      return
    end
    source = require('tools.' .. args.method .. '.' .. args.name).with(with_config)
  elseif lib_name then
    source = require(lib_name .. '.' .. args.method .. '.' .. args.name).with(with_config)
  else
    source = require('null-ls').builtins[args.method][args.name].with(with_config)
  end

  if is_external_tool then
    return vim.fn.executable(args.tool == nil and args.name or args.tool) == 1 and source
  else
    return source
  end
end

return M
