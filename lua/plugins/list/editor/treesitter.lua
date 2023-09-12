return {
  {
    -- Config for Treesitter
    'nvim-treesitter/nvim-treesitter',
    name = 'treesitter',
    event = { 'BufRead', 'BufNewFile', 'FileType' },
    cmd = 'TSInstall',
  },
  {
    -- Text object for Treesitter
    'nvim-treesitter/nvim-treesitter-textobjects',
    name = 'text_object',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
  {
    -- Automatically close and rename HTML tag
    'windwp/nvim-ts-autotag',
    name = 'autotag',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
  {
    -- Automatically insert end keyword
    'RRethy/nvim-treesitter-endwise',
    name = 'endwise',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
}
