local neomux = require('Navigator')

return {
  {
    '<S-Left>',
    function()
      neomux.left()
    end,
    desc = 'Navigate to left window',
    mode = { 'n', 't' },
  },
  {
    '<S-Down>',
    function()
      neomux.down()
    end,
    desc = 'Navigate to down window',
    mode = { 'n', 't' },
    noremap = true,
  },
  {
    '<S-Up>',
    function()
      neomux.up()
    end,
    desc = 'Navigate to up window',
    mode = { 'n', 't' },
    noremap = true,
  },
  {
    '<S-Right>',
    function()
      neomux.right()
    end,
    desc = 'Navigate to right window',
    mode = { 'n', 't' },
    noremap = true,
  },
  {
    '<C-\\>',
    function()
      neomux.previous()
    end,
    desc = 'Navigate to previous window',
    mode = { 'n', 't' },
    noremap = true,
  },
}
