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
    event = 'BufReadPre',
  },
  {
    -- Granular project configuration
    'tpope/vim-projectionist',
    lazy = false,
  },
}
