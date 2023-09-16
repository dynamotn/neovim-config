return {
  {
    -- Refactoring library
    'ThePrimeagen/refactoring.nvim',
    name = 'refactoring',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
}
