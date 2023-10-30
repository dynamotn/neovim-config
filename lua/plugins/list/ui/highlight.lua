return {
  {
    -- Indent guide
    'lukas-reineke/indent-blankline.nvim',
    name = 'indent',
    main = 'ibl',
    event = { 'BufReadPost', 'BufNewFile' },
  },
  {
    -- Indent guide animation
    'echasnovski/mini.indentscope',
    name = 'indent_scope',
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
