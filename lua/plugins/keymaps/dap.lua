return {
  ['<Space>qb'] = { dynamo_cmdcr('lua require("dap").toggle_breakpoint()'), 'Mark or delete breakpoints' },
  ['<Space>qz'] = { dynamo_cmdcr('lua require("dap").clear_breakpoints()'), 'Clear all breakpoints' },
}
