return {
  {
    '<Space>lt',
    function()
      return require('pantran').motion_translate() .. 'aw'
    end,
    desc = 'Translate',
    expr = true,
  },
  {
    '<Space>lt',
    require('pantran').motion_translate,
    desc = 'Translate',
    mode = 'v',
    expr = true,
  },
}
