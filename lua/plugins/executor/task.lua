return {
  -- Task runner
  { import = 'lazyvim.plugins.extras.editor.overseer' },
  {
    'stevearc/overseer.nvim',
    opts = {
      templates = { 'builtin', 'dytask' },
      component_aliases = {
        output = {
          {
            'open_output',
            on_complete = 'always',
            direction = 'dock',
            focus = true,
          },
        },
      },
    },
  },
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
