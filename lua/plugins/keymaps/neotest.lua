return {
  {
    '<leader>tn',
    function()
      require('neotest').run.run()
    end,
    desc = 'Run the nearest test',
  },
  {
    '<leader>tf',
    function()
      require('neotest').run.run(vim.fn.expand('%'))
    end,
    desc = 'Run the current file',
  },
  {
    '<leader>td',
    function()
      require('neotest').run.run({ strategy = 'dap' })
    end,
    desc = 'Debug the nearest test',
  },
}
