return {
  -- Task runner
  { import = 'lazyvim.plugins.extras.editor.overseer' },
  {
    -- Lualine extensions for task runner
    'lualine.nvim',
    opts = {
      special_filetypes = {
        OverseerList = 'List tasks',
      },
    },
  },
}
