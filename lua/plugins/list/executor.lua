return {
  {
    -- Debug Adapter implementation
    'mfussenegger/nvim-dap',
    name = 'dap',
    dependencies = { 'dap_ui', 'dap_virtual_text' },
  },
  {
    -- DAP manager
    'jayp0521/mason-nvim-dap.nvim',
    name = 'mason_dap',
    event = 'BufReadPre',
    dependencies = { 'mason', 'dap' },
  },
  {
    -- Test integration
    'nvim-neotest/neotest',
    name = 'neotest',
    dependencies = {
      {
        -- Test runner compatibility that support vim-test
        'nvim-neotest/neotest-vim-test',
        dependencies = { 'vim-test/vim-test' },
      },
    },
  },
  {
    -- Task runner
    'stevearc/overseer.nvim',
    name = 'overseer',
  },
}
