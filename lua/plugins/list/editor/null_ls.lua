return {
  {
    -- Config for non-LSP sources (linter and formatter)
    'jose-elias-alvarez/null-ls.nvim',
    name = 'null_ls',
    event = 'VeryLazy',
    dependencies = { 'refactoring' },
  },
  {
    -- Linter and Formatter manager
    'jayp0521/mason-null-ls.nvim',
    name = 'mason_null_ls',
    dependencies = { 'mason' },
  },
}
