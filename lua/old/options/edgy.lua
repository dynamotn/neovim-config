local edgy = require('edgy')

edgy.setup({
  bottom = {
    {
      ft = 'toggleterm',
      size = { height = 0.4 },
      filter = function(_, win)
        return vim.api.nvim_win_get_config(win).relative == ''
      end,
    },
    {
      ft = 'noice',
      size = { height = 0.4 },
      filter = function(_, win)
        return vim.api.nvim_win_get_config(win).relative == ''
      end,
    },
    'Trouble',
    { ft = 'qf', title = 'QuickFix' },
    {
      ft = 'help',
      size = { height = 20 },
      -- don't open help files in edgy that we're editing
      filter = function(buf)
        return vim.bo[buf].buftype == 'help'
      end,
    },
    {
      title = 'Test Output',
      ft = 'neotest-output-panel',
      size = { height = 15 },
    },
  },
  left = {
    {
      title = 'File Explorer',
      ft = 'neo-tree',
      filter = function(buf)
        return vim.b[buf].neo_tree_source == 'filesystem'
      end,
      open = function()
        vim.api.nvim_input('<esc><space>e')
      end,
      size = { height = 0.5 },
    },
    { title = 'Test Summary', ft = 'neotest-summary' },
    {
      title = 'Git Explorer',
      ft = 'neo-tree',
      filter = function(buf)
        return vim.b[buf].neo_tree_source == 'git_status'
      end,
      open = 'Neotree position=right git_status',
    },
    {
      title = 'Buffers Explorer',
      ft = 'neo-tree',
      filter = function(buf)
        return vim.b[buf].neo_tree_source == 'buffers'
      end,
      open = 'Neotree position=top buffers',
    },
    {
      title = 'Database Explorer',
      ft = 'dbui',
      open = 'DBUI',
    },
  },
  right = {
    {
      title = 'Outline',
      ft = 'sagaoutline',
      open = 'Lspsaga outline',
    },
  },
})
