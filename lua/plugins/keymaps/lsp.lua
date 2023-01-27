return {
  {
    'gd',
    function()
      vim.lsp.buf.definition()
    end,
    desc = 'Go to definition',
  },
  {
    'gi',
    function()
      vim.lsp.buf.implementation()
    end,
    desc = 'Go to implementation',
  },
  {
    'gt',
    function()
      vim.lsp.buf.type_definition()
    end,
    desc = 'Go to type definition',
  },
  {
    'gr',
    function()
      vim.lsp.buf.references()
    end,
    desc = 'Go to references',
  },
  {
    'K',
    function()
      vim.lsp.buf.hover()
    end,
    desc = 'Hover document',
  },
  {
    '<leader>k',
    function()
      vim.lsp.buf.signature_help()
    end,
    desc = 'Signature help',
  },
  {
    '<Space>la',
    function()
      vim.lsp.buf.code_action()
    end,
    desc = 'Code Action',
  },
  {
    '<Space>li',
    function()
      vim.lsp.buf.incoming_calls()
    end,
    desc = 'Show incoming calls',
  },
  {
    '<Space>ll',
    function()
      vim.lsp.codelens.run()
    end,
    desc = 'Code Lense',
  },
  {
    '<Space>lo',
    function()
      vim.lsp.buf.outgoing_calls()
    end,
    desc = 'Show outgoing calls',
  },
  {
    '<Space>lr',
    function()
      vim.lsp.buf.rename()
    end,
    desc = 'Rename',
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
