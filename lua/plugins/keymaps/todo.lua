local trouble = require('trouble')

return {
  {
    '<Space>pt',
    function()
      trouble.toggle({ mode = 'todo' })
    end,
    desc = 'Show TODO',
  },
}
