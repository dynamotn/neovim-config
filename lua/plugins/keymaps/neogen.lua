local neogen = require('neogen')

return {
  {
    '<Space>ld',
    function()
      neogen.generate()
    end,
    desc = 'Generate documentation',
  },
}
