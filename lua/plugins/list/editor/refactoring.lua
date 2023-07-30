return {
  {
    -- Refactoring library
    'ThePrimeagen/refactoring.nvim',
    name = 'refactoring',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
}
