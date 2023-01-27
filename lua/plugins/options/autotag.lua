local autotag = require('nvim-ts-autotag')

require('nvim-treesitter.configs').setup({
  autotag = {
    enable = true,
  },
})
