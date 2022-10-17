local present, mason_lsp_config = pcall(require, 'mason-lspconfig')

if not present then
  return
end

local configs = require('languages').setup_ls()
local lsp_servers = {}
for server_name, _ in pairs(configs) do
  table.insert(lsp_servers, server_name)
end
mason_lsp_config.setup({
  ensure_installed = lsp_servers,
})
