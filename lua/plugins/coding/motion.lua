return {
  -- Create key strokes
  { import = 'lazyvim.plugins.extras.editor.harpoon2' },
  -- Action for surrounding
  { import = 'lazyvim.plugins.extras.coding.mini-surround' },
  {
    -- Interact and manipulate marks
    'chentoast/marks.nvim',
    event = 'VeryLazy',
    opts = {
      default_mappings = true,
    },
  },
}
