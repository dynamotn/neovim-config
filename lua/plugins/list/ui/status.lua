return {
  {
    -- Status line
    'nvim-lualine/lualine.nvim',
    name = 'lualine',
    event = 'UIEnter',
    dependencies = { require('core.defaults').colorscheme },
  },
  {
    -- Status column
    'luukvbaal/statuscol.nvim',
    name = 'statuscol',
    event = 'UIEnter',
  },
  {
    -- Buffer and tab line
    'akinsho/bufferline.nvim',
    name = 'bufferline',
    event = 'UIEnter',
    dependencies = { require('core.defaults').colorscheme, 'icon' },
    cond = not vim.g.started_by_firenvim,
  },
  {
    -- Winbar to show context of current position
    'Bekaboo/dropbar.nvim',
    name = 'dropbar',
    event = 'UIEnter',
  },
}
