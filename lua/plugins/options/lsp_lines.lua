local lsp_lines = require('lsp_lines')

vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = { only_current_line = true },
})
lsp_lines.setup({})
