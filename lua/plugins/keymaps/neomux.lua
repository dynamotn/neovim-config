return {
  {
    '<S-Left>',
    function()
      require('Navigator').left()
    end,
    desc = 'Navigate to left window',
    mode = { 'n', 't' },
  },
  {
    '<S-Down>',
    function()
      require('Navigator').down()
    end,
    desc = 'Navigate to down window',
    mode = { 'n', 't' },
    noremap = true,
  },
  {
    '<S-Up>',
    function()
      require('Navigator').up()
    end,
    desc = 'Navigate to up window',
    mode = { 'n', 't' },
    noremap = true,
  },
  {
    '<S-Right>',
    function()
      require('Navigator').right()
    end,
    desc = 'Navigate to right window',
    mode = { 'n', 't' },
    noremap = true,
  },
  {
    '<C-\\>',
    function()
      require('Navigator').previous()
    end,
    desc = 'Navigate to previous window',
    mode = { 'n', 't' },
    noremap = true,
  },
}
