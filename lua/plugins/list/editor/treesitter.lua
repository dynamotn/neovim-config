return {
  {
    -- Config for Treesitter
    'nvim-treesitter/nvim-treesitter',
    name = 'treesitter',
    event = { 'BufReadPost', 'BufNewFile' },
    cmd = { 'TSInstall', 'TSUpdateSync' },
    build = function()
      require('nvim-treesitter.install').update({ with_sync = true })()
    end,
  },
  {
    -- Text object for Treesitter
    'nvim-treesitter/nvim-treesitter-textobjects',
    name = 'text_object',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
  {
    -- Automatically close and rename HTML tag
    'windwp/nvim-ts-autotag',
    name = 'autotag',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
  {
    -- Automatically insert end keyword
    'RRethy/nvim-treesitter-endwise',
    name = 'endwise',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
  {
    -- Show code context
    'nvim-treesitter/nvim-treesitter-context',
    name = 'context',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
}
