return {
  {
    -- Improve messages, cmdline, popups & LSP
    'folke/noice.nvim',
    name = 'noice',
    event = 'VeryLazy',
    dependencies = { 'nui' },
    cond = not vim.g.started_by_firenvim,
  },
  {
    -- Notification
    'rcarriga/nvim-notify',
    name = 'notify',
    event = 'UIEnter',
  },
  {
    -- Window layouts
    'folke/edgy.nvim',
    name = 'edgy',
    event = 'VeryLazy',
  },
  {
    -- Automatically expand window
    'anuvyklack/windows.nvim',
    name = 'winex',
    event = 'WinNew',
    dependencies = {
      { 'anuvyklack/middleclass' },
      { 'anuvyklack/animation.nvim' },
    },
  },
}
