local flash = require('flash')

return {
  {
    '<Space>bm',
    function()
      flash.jump()
    end,
    desc = 'Move cursor to anywhere',
  },
}
