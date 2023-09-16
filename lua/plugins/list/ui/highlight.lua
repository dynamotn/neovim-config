return {
  {
    -- Indent guide
    'lukas-reineke/indent-blankline.nvim',
    name = 'indent',
    event = { 'BufReadPost', 'BufNewFile' },
  },
  {
    -- Column highlight
    'm4xshen/smartcolumn.nvim',
    name = 'smartcolumn',
    event = { 'BufReadPost', 'BufNewFile' },
  },
  {
    -- Color highlight
    'NvChad/nvim-colorizer.lua',
    name = 'colorizer',
    event = { 'BufReadPost', 'BufNewFile' },
  },
  {
    -- Rainbow parentheses
    'HiPhish/rainbow-delimiters.nvim',
    name = 'rainbow',
    event = { 'BufReadPost', 'BufNewFile' },
  },
}
