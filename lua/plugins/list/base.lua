return {
  {
    -- Base Lua functions
    'nvim-lua/plenary.nvim',
    name = 'plenary',
  },
  DEBUG and {
      -- View startup timing
      'dstein64/vim-startuptime',
      cmd = 'StartupTime',
    } or nil,
  {
    -- Show guide of keymaps
    'folke/which-key.nvim',
    name = 'whichkey',
    lazy = false,
  },
}
