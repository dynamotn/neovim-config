return {
  { -- Neovim debugger
    'jbyuki/one-small-step-for-vimkind',
    name = 'osv',
    enabled = DEBUG or FULL,
  },
  {
    -- Neovim development
    'folke/neodev.nvim',
    name = 'neodev',
  },
}
