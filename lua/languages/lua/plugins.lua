return {
  DEBUG and {
      -- Neovim debugger
      'jbyuki/one-small-step-for-vimkind',
      name = 'osv',
    } or {},
  { 'folke/neodev.nvim', opts = {} },
}
