return {
  ['<leader>db'] = { dynamo_cmdcr('lua require("dap").toggle_breakpoint()'), 'Mark or delete breakpoints' },
  ['<leader>dz'] = { dynamo_cmdcr('lua require("dap").clear_breakpoints()'), 'Clear all breakpoints' },
  ['<leader>dd'] = { dynamo_cmdcr('lua require("dap").continue()'), 'Launch debug / Resume execution' },
  ['<F6>'] = { dynamo_cmdcr('lua require("dap").continue()'), 'Launch debug / Resume execution' },
  ['<leader>dt'] = { dynamo_cmdcr('lua require("dap").terminate()'), 'Terminate debug' },
  ['<leader>do'] = { dynamo_cmdcr('lua require("dap").repl.open()'), 'Open inspecting the state via the built-in REPL' },
}
