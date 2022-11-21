local present, lsp_inlay = pcall(require, 'lsp-inlayhints')

if not present then
  return
end

lsp_inlay.setup({})
