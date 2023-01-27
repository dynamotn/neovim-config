local hop = require('hop')
local directions = require('hop.hint').HintDirection

return {
  {
    '<Space>bm',
    function()
      hop.hint_anywhere()
    end,
    desc = 'Move cursor to anywhere',
  },
  {
    'f',
    function()
      hop.hint_char1({
        direction = directions.AFTER_CURSOR,
        current_line_only = true,
      })
    end,
    desc = 'Move cursor forward inline',
  },
  {
    'F',
    function()
      hop.hint_char1({
        direction = directions.BEFORE_CURSOR,
        current_line_only = true,
      })
    end,
    desc = 'Move cursor backward inline',
  },
  {
    't',
    function()
      hop.hint_char1({
        direction = directions.AFTER_CURSOR,
        current_line_only = true,
        hint_offset = -1,
      })
    end,
    desc = 'Move cursor before forward inline',
  },
  {
    'T',
    function()
      hop.hint_char1({
        direction = directions.BEFORE_CURSOR,
        current_line_only = true,
        hint_offset = 1,
      })
    end,
    desc = 'Move cursor after backward inline',
  },
}
