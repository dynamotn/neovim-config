local present, mason = pcall(require, 'mason')

if not present then
  return
end

mason.setup({})

local present, mason_lsp_config = pcall(require, 'mason-lspconfig')

if not present then
  return
end
mason_lsp_config.setup({
  automatic_installation = true,
})
