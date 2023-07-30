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
    event = { 'BufRead', 'BufNewFile' },
  },
  {
    -- Color highlight
    'NvChad/nvim-colorizer.lua',
    name = 'colorizer',
    event = { 'BufRead', 'BufNewFile' },
  },
  {
    -- Rainbow parentheses
    'HiPhish/rainbow-delimiters.nvim',
    name = 'rainbow',
    event = { 'BufRead', 'BufNewFile' },
  },
}
