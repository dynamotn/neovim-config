local extras = require('util.extras')

local function dial_sequence(direction, mode)
  local select =
    extras.cmdcr([[lua require("dial.command").select_augend_]] .. mode .. '(require("util.extras").get_dial_group())')
  local setopfunc = extras.cmdcr([[let &opfunc="dial#operator#]] .. direction .. '_' .. mode .. [["]])
  local textobj = mode == 'normal' and extras.cmdcr([[lua require("dial.command").textobj()]]) or ''
  return select .. setopfunc .. 'g@' .. textobj
end

return {
  { '<C-a>', dial_sequence('increment', 'normal'), desc = 'Increment' },
  { '<C-x>', dial_sequence('decrement', 'normal'), desc = 'Decrement' },
  {
    '<C-a>',
    dial_sequence('increment', 'visual'),
    desc = 'Increment',
    mode = 'v',
  },
  {
    '<C-x>',
    dial_sequence('decrement', 'visual'),
    desc = 'Decrement',
    mode = 'v',
  },
  {
    'g<C-a>',
    dial_sequence('increment', 'gvisual'),
    desc = 'Increment',
    mode = 'v',
  },
  {
    'g<C-x>',
    dial_sequence('decrement', 'gvisual'),
    desc = 'Decrement',
    mode = 'v',
  },
}
