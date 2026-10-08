return {
  {
    -- Task runner
    'stevearc/overseer.nvim',
    lazy = false, -- plugin is self-lazy-loading
    cmd = {
      'OverseerOpen',
      'OverseerClose',
      'OverseerToggle',
      'OverseerRun',
      'OverseerTaskAction',
    },
    -- stylua: ignore
    keys = {
      { '<leader>ow', '<cmd>OverseerToggle!<cr>', desc = 'Task list' },
      { '<leader>oo', '<cmd>OverseerRun<cr>', desc = 'Run task' },
      { '<leader>ot', '<cmd>OverseerTaskAction<cr>', desc = 'Task action' },
      {
        '<leader>ol',
        function()
          local overseer = require('overseer')
          local task = overseer.list_tasks({ include_ephemeral = true })[1]
          if not task then return vim.notify('No task to restart', vim.log.levels.WARN) end
          overseer.run_action(task, 'restart')
        end,
        desc = 'Restart last task',
      },
    },
    opts = {
      dap = false,
      component_aliases = {
        output = {
          {
            'open_output',
            on_complete = 'always',
            direction = 'dock',
            focus = true,
          },
        },
      },
      task_list = {
        keymaps = {
          ['<C-j>'] = false,
          ['<C-k>'] = false,
        },
      },
      form = {
        win_opts = {
          winblend = 0,
        },
      },
      task_win = {
        win_opts = {
          winblend = 0,
        },
      },
    },
  },
  {
    'catppuccin',
    optional = true,
    opts = {
      integrations = { overseer = true },
    },
  },
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>o', group = 'overseer' },
      },
    },
  },
  {
    'folke/edgy.nvim',
    optional = true,
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        title = 'Overseer',
        ft = 'OverseerList',
        open = function() require('overseer').open() end,
      })
    end,
  },
  {
    -- Run tests through overseer
    'nvim-neotest/neotest',
    optional = true,
    opts = function(_, opts)
      opts.consumers = opts.consumers or {}
      opts.consumers.overseer = require('neotest.consumers.overseer')
    end,
  },
  {
    -- Run the build task of a launch configuration before debugging
    'mfussenegger/nvim-dap',
    optional = true,
    opts = function() require('overseer').enable_dap() end,
  },
  {
    -- Lualine extensions for task runner
    'lualine.nvim',
    opts = {
      special_filetypes = {
        OverseerList = 'List tasks',
      },
    },
  },
}
