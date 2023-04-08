return {
  { -- Org managed plugin
    'nvim-neorg/neorg',
    name = 'neorg',
    dependencies = {
      { 'plenary' },
      { 'nvim-neorg/neorg-telescope' }, -- Telescope for Neorg
      { 'max397574/neorg-zettelkasten' }, -- Zettelkasten for Neorg
    },
  },
}
