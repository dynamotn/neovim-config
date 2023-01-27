local pantran = require('pantran')

return {
  {
    '<Space>lt',
    function()
      return pantran.motion_translate() .. 'aw'
    end,
    desc = 'Translate',
    expr = true,
  },
  {
    '<Space>lt',
    pantran.motion_translate,
    desc = 'Translate',
    mode = 'v',
    expr = true,
  },
}
