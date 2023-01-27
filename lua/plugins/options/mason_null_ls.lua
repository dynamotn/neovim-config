local mason_null_ls_config = require('mason-null-ls')

local configs = require('languages').setup_null_ls()
local tools = {}
for tool, _ in pairs(configs) do
  table.insert(tools, tool)
end
mason_null_ls_config.setup({
  automatic_installation = true,
})
