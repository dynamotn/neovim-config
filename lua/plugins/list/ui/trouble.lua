return {
  {
    -- Highlight quickfix and diagnostics
    'folke/trouble.nvim',
    name = 'trouble',
    cmd = 'Trouble',
  },
  {
    -- Show virtual lines for LSP diagnostics
    url = 'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    name = 'lsp_lines',
    event = 'UIEnter',
  },
  {
    -- Highlight TODO comments
    'folke/todo-comments.nvim',
    name = 'todo',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'plenary' },
  },
}
