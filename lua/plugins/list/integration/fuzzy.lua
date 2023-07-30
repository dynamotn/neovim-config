return {
  {
    -- Engine
    'nvim-telescope/telescope.nvim',
    name = 'telescope',
    dependencies = {
      'plenary',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }, -- Increase performance with fzf (native port from Go to C)
    },
    cmd = 'Telescope',
  },
  {
    -- Abstract layer for fuzzy finder
    'tzachar/fuzzy.nvim',
    name = 'fuzzy',
  },
}
