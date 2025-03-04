return {
  {
    -- Debug Treesitter
    'nvim-treesitter/playground',
    dependencies = { 'nvim-treesitter' },
    cmd = 'TSPlaygroundToggle',
  },
  {
    -- Lualine extension for Treesitter playground
    'lualine.nvim',
    opts = {
      special_filetypes = {
        tsplayground = 'Debug Treesitter',
      },
    },
  },
}
