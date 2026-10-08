return {
  {
    -- Render images and diagrams
    'folke/snacks.nvim',
    opts = {
      image = {
        enabled = true,
        backend = 'kitty',
      },
    },
    -- `plugins.ui.snacks` loads the d2 renderer once Snacks is set up
  },
  {
    -- Render `:help` pages: headings, tables, code blocks, tags and links
    'OXY2DEV/helpview.nvim',
    -- Loads itself on a help buffer; lazy-loading it only delays the first
    -- help page
    lazy = false,
  },
}
