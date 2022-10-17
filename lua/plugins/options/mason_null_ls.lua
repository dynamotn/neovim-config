local present, mason_null_ls_config = pcall(require, 'mason-null-ls')

if not present then
  return
end

local configs = require('languages').setup_null_ls()
local tools = {}
for tool, _ in pairs(configs) do
  table.insert(tools, tool)
end
mason_null_ls_config.setup({
  ensure_installed = tools,
})
