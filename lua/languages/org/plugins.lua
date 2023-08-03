return {
  { -- Org managed plugin
    'nvim-neorg/neorg',
    name = 'neorg',
    dependencies = {
      { 'plenary' },
      { 'nvim-neorg/neorg-telescope' }, -- Telescope for Neorg
    },
    cmd = { 'Neorg' },
    lazy = false,
  },
  { 'navarasu/onedark.nvim' },
  { 'lukas-reineke/headlines.nvim', dependencies = { 'treesitter' }, name = 'headlines' }, -- Highlight for headlines, codeblocks
}
