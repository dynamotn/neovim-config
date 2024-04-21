return {
  {
    -- Config for LSP server
    'neovim/nvim-lspconfig',
    name = 'lsp',
    event = 'BufReadPre',
    dependencies = { 'neoconf' },
  },
  {
    -- LSP for codeblocks
    'jmbuhr/otter.nvim',
    name = 'otter',
    event = 'BufReadPre',
    dependencies = { 'cmp', 'lsp' },
  },
  {
    -- LSP server manager
    'williamboman/mason-lspconfig.nvim',
    name = 'mason_lsp',
    event = 'BufReadPre',
    dependencies = { 'mason' },
  },
}
