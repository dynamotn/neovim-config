return {
  -- Code outline sidebar
  { import = 'lazyvim.plugins.extras.editor.outline' },
  {
    -- Lualine extension for Outline
    'lualine.nvim',
    opts = {
      special_filetypes = {
        Outline = 'Outline',
      },
    },
  },
}
