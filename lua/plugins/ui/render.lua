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
    config = function(_, opts)
      require('snacks').setup(opts)
      require('tools.diagram.d2.snacks')
    end,
  },
  {
    -- Render `:help` pages: headings, tables, code blocks, tags and links
    'OXY2DEV/helpview.nvim',
    -- Loads itself on a help buffer; lazy-loading it only delays the first
    -- help page
    lazy = false,
  },
}
