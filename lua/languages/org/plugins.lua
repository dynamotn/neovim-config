return {
  { -- Org managed plugin
    'nvim-neorg/neorg',
    name = 'neorg',
    dependencies = {
      { 'max397574/neorg-kanban' }, -- Kanban view for GTD
      { 'nvim-neorg/neorg-telescope' }, -- Telescope for Neorg
      { 'max397574/neorg-zettelkasten' }, -- Zettelkasten for Neorg
    },
  },
}
