return {
  {
    -- Config for non-LSP sources (linter and formatter)
    'nvimtools/none-ls.nvim',
    name = 'null_ls',
    event = 'VeryLazy',
    dependencies = {
      'refactoring',
      'nvimtools/none-ls-extras.nvim',
    },
  },
}
