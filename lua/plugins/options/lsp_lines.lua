local present, lsp_lines = pcall(require, 'lsp_lines')

if not present then
  return
end

vim.diagnostic.config({
  virtual_text = false,
})
lsp_lines.setup({})
