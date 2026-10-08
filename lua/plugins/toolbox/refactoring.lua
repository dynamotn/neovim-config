return {
  { 'lewis6991/async.nvim', lazy = true },
  {
    -- Refactoring
    --
    -- Its debug-print keys are left to debugprint.nvim (`plugins.executor`),
    -- whose prints the other's cleanup would not find.
    'ThePrimeagen/refactoring.nvim',
    -- Loaded by its keys or `:Refactor`, not with every file
    cmd = 'Refactor',
    keys = {
      { '<leader>r', '', desc = '+refactor', mode = { 'n', 'x' } },
      {
        '<leader>rs',
        function() return require('refactoring').select_refactor() end,
        mode = { 'n', 'x' },
        desc = 'Select Refactor',
      },
      {
        '<leader>ri',
        function() return require('refactoring').inline_var() end,
        mode = { 'n', 'x' },
        desc = 'Inline Variable',
        expr = true,
      },
      {
        '<leader>rf',
        function() return require('refactoring').extract_func() end,
        mode = { 'n', 'x' },
        desc = 'Extract Function',
        expr = true,
      },
      {
        '<leader>rF',
        function() return require('refactoring').extract_func_to_file() end,
        mode = { 'n', 'x' },
        desc = 'Extract Function To File',
        expr = true,
      },
      {
        '<leader>rx',
        function() return require('refactoring').extract_var() end,
        mode = { 'n', 'x' },
        desc = 'Extract Variable',
        expr = true,
      },
    },
    opts = {},
  },
}
