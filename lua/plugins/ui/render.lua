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
}
