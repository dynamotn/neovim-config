local neotest = require('neotest')

return {
  {
    '<leader>tn',
    function()
      neotest.run.run()
    end,
    desc = 'Run the nearest test',
  },
  {
    '<leader>tf',
    function()
      neotest.run.run(vim.fn.expand('%'))
    end,
    desc = 'Run the current file',
  },
  {
    '<leader>td',
    function()
      neotest.run.run({ strategy = 'dap' })
    end,
    desc = 'Debug the nearest test',
  },
}
