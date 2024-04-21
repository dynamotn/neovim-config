return {
  {
    -- Commenting
    'echasnovski/mini.comment',
    name = 'comment',
    event = 'VeryLazy',
  },
  {
    -- Comment based on cursor location
    'JoosepAlviste/nvim-ts-context-commentstring',
    name = 'context_comment',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'treesitter', 'comment' },
  },
  {
    -- Generate annotation
    'danymat/neogen',
    name = 'neogen',
    dependencies = { 'treesitter' },
  },
}
