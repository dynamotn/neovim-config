local symbols_outline = require('symbols-outline')

return {
  {
    '<F2>',
    function()
      symbols_outline.toggle_outline()
    end,
    desc = 'Show outline',
  },
  {
    '<Space>ls',
    function()
      symbols_outline.toggle_outline()
    end,
    desc = 'Show outline',
  },
}
