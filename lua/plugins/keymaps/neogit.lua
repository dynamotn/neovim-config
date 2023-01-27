local neogit = require('neogit')

return {
  {
    '<F7>',
    function()
      neogit.open()
    end,
    desc = 'Show Neogit',
  },
  {
    '<Space>gs',
    function()
      neogit.open()
    end,
    desc = 'Show Neogit',
  },
}
