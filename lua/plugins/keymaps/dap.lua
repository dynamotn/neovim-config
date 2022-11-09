return {
  ['<Space>qb'] = { dynamo_cmdcr('lua require("dap").toggle_breakpoint()'), 'Mark or delete breakpoints' },
  ['<Space>qz'] = { dynamo_cmdcr('lua require("dap").clear_breakpoints()'), 'Clear all breakpoints' },
  ['<Space>qd'] = { dynamo_cmdcr('lua require("dap").continue()'), 'Launch debug / Resume execution' },
  ['<F6>'] = { dynamo_cmdcr('lua require("dap").continue()'), 'Launch debug / Resume execution' },
  ['<Space>qo'] = { dynamo_cmdcr('lua require("dap").repl.open()'), 'Open inspecting the state via the built-in REPL' },
}
