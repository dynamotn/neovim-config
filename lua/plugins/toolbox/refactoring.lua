return {
  -- Refactoring
  { import = 'lazyvim.plugins.extras.editor.refactoring' },
  {
    -- Its debug-print keys go to debugprint.nvim (`plugins.executor`), whose
    -- prints the other's cleanup would not find. Dropped here, after the
    -- import that adds them, or they would just be added back.
    'ThePrimeagen/refactoring.nvim',
    keys = {
      { '<leader>rp', false, mode = { 'n', 'x' } },
      { '<leader>rP', false },
      { '<leader>rc', false },
    },
  },
}
