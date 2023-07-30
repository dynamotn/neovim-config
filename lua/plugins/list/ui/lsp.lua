return {
  {
    -- UI view for LSP
    'nvimdev/lspsaga.nvim',
    name = 'lspsaga',
    event = { 'LspAttach' },
  },
  {
    -- Inlayhints for LSP
    'lvimuser/lsp-inlayhints.nvim',
    name = 'lsp_inlay',
    event = { 'BufRead', 'BufNewFile' },
  },
}
