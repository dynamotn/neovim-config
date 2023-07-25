return {
  {
    '<leader>k',
    function()
      vim.lsp.buf.signature_help()
    end,
    desc = 'Signature help',
  },
  {
    '<Space>ll',
    function()
      vim.lsp.codelens.run()
    end,
    desc = 'Code Lense',
  },
  {
    '<Space>ff',
    function()
      vim.lsp.buf.formatting()
    end,
    desc = 'File formatting',
  },
  {
    '<Space>la',
    function()
      vim.lsp.buf.range_code_action()
    end,
    desc = 'Code Action',
    mode = 'v',
  },
  {
    '<Space>ff',
    function()
      vim.lsp.buf.range_formatting()
    end,
    desc = 'File formatting with range',
    mode = 'v',
  },
}
