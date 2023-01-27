return {
  {
    '<leader>db',
    function()
      vim.ui.input({ prompt = 'Breakpoint condition: ' }, function(input)
        require('dap').set_breakpoint(input)
      end)
    end,
    desc = 'Mark breakpoint',
  },
  {
    '<leader>dl',
    function()
      vim.ui.input({ prompt = 'Log point message: ' }, function(input)
        require('dap').set_breakpoint(nil, nil, input)
      end)
    end,
    desc = 'Mark log point',
  },
  {
    '<leader>de',
    function()
      require('dap').set_exception_breakpoints()
    end,
    desc = 'Mark exception point',
  },
  {
    '<leader>dz',
    function()
      require('dap').clear_breakpoints()
    end,
    desc = 'Clear all breakpoints',
  },
  {
    '<leader>dd',
    function()
      require('dap').continue()
    end,
    desc = 'Launch debug / Resume execution',
  },
  {
    '<F6>',
    function()
      require('dap').continue()
    end,
    desc = 'Launch debug / Resume execution',
  },
  {
    '<leader>dt',
    function()
      require('dap').terminate()
    end,
    desc = 'Terminate debug',
  },
  {
    '<leader>do',
    function()
      require('dap').repl.open()
    end,
    desc = 'Open inspecting the state via the built-in REPL',
  },
}
