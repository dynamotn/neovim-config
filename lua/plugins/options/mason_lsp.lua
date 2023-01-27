local mason_lsp_config = require('mason-lspconfig')
local configs = require('languages').setup_ls()

local lsp_servers = {}
for server_name, _ in pairs(configs) do
  table.insert(lsp_servers, server_name)
end

mason_lsp_config.setup({
  automatic_installation = true,
})
