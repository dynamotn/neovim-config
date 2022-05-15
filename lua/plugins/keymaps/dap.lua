return {
    ['<Space>qb'] = { '<cmd>lua require("dap").toggle_breakpoint()<CR>', 'Mark or delete breakpoints' },
    ['<Space>qz'] = { '<cmd>lua require("dap").clear_breakpoints()<CR>', 'Clear all breakpoints' },
}
