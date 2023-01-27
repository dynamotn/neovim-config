local bufferline = require('bufferline')

return {
  {
    '<Space>bj',
    function()
      bufferline.pick_buffer()
    end,
    desc = 'Pick to jump',
  },
}
