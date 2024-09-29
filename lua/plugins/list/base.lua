return {
  {
    -- Base Lua functions
    'nvim-lua/plenary.nvim',
    name = 'plenary',
  },
  {
    -- View startup timing
    'dstein64/vim-startuptime',
    cmd = 'StartupTime',
    enabled = DEBUG,
  },
  {
    -- Show guide of keymaps
    'folke/which-key.nvim',
    name = 'whichkey',
    event = 'VeryLazy',
  },
}
