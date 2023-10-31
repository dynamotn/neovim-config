return {
  {
    -- Git TUI
    'TimUntersberger/neogit',
    name = 'neogit',
    dependencies = { 'sindrets/diffview.nvim' },
  },
  {
    -- Git decoration
    'lewis6991/gitsigns.nvim',
    name = 'gitsigns',
    event = { 'BufReadPre', 'BufNewFile' },
  },
  {
    -- Granular project configuration
    'tpope/vim-projectionist',
    event = { 'BufReadPre', 'BufNewFile' },
  },
  {
    -- Manage global and project-local settings
    'folke/neoconf.nvim',
    name = 'neoconf',
    cmd = 'Neoconf',
    event = { 'BufReadPre', 'BufNewFile' },
  },
}
