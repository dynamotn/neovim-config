return {
  -- Highlight patterns (colors)
  { import = 'lazyvim.plugins.extras.util.mini-hipatterns' },
  {
    -- Rainbow parentheses
    'HiPhish/rainbow-delimiters.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    submodules = false,
    opts = function()
      local rainbow = require('rainbow-delimiters')
      return {
        strategy = {
          [''] = rainbow.strategy['global'],
          vim = rainbow.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
        },
      }
    end,
    main = 'rainbow-delimiters.setup',
  },
}
