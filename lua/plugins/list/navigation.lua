return {
  { -- File explorer
    'nvim-neo-tree/neo-tree.nvim',
    name = 'neotree',
    cmd = 'Neotree',
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
  },
  {
    -- Window switcher
    url = 'https://gitlab.com/yorickpeterse/nvim-window',
    name = 'window',
  },
  {
    -- Easymotion
    'folke/flash.nvim',
    name = 'flash',
    event = 'VeryLazy',
  },
  {
    -- Smoothly navigate between neovim and tmux
    'numToStr/Navigator.nvim',
    name = 'neomux',
    event = 'UIEnter',
  },
}
