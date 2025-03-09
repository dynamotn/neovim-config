local cmp_util = require('util.cmp')

return {
  -- Debug Adapter implementation
  { import = 'lazyvim.plugins.extras.dap.core' },
  {
    -- Lualine extensions for DAP
    'lualine.nvim',
    opts = {
      special_filetypes = {
        dapui_scopes = 'Scopes',
        dapui_breakpoints = 'Breakpoints',
        dapui_stacks = 'Stacks',
        dapui_watches = 'Watches',
        ['dap-repl'] = 'REPL',
        dapui_console = 'Console',
      },
    },
  },
  {
    -- Completion for DAP
    'blink.cmp',
    dependencies = {
      {
        'rcarriga/cmp-dap',
        init = function()
          _G.completion_sources =
            vim.tbl_extend('force', _G.completion_sources, {
              dap = '「DAP」',
            })
        end,
      },
    },
    opts = {
      sources = {
        compat = { 'dap' },
        per_filetype = {
          ['dap-repl'] = cmp_util.sources('dap'),
          dapui_watches = cmp_util.sources('dap'),
          dapui_hover = cmp_util.sources('dap'),
        },
      },
    },
  },
}
