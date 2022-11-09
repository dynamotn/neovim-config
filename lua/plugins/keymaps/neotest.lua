return {
  ['<leader>tn'] = { dynamo_cmdcr('lua require("neotest").run.run()'), 'Run the nearest test' },
  ['<leader>tf'] = { dynamo_cmdcr('lua require("neotest").run.run(vim.fn.expand("%"))'), 'Run the current file' },
  ['<leader>td'] = { dynamo_cmdcr('lua require("neotest").run.run({strategy = "dap"}))'), 'Debug the nearest test' },
}
