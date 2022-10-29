local function dial_sequence(direction, mode)
  local select = dynamo_cmdcr([[lua require("dial.command").select_augend_]] .. mode .. '(dynamo_dial_group())')
  local setopfunc = dynamo_cmdcr([[let &opfunc="dial#operator#]] .. direction .. '_' .. mode .. [["]])
  local textobj = mode == 'normal' and dynamo_cmdcr([[lua require("dial.command").textobj()]]) or ''
  return select .. setopfunc .. 'g@' .. textobj
end

return function(whichkey, _)
  whichkey.register({
    ['<C-a>'] = {
      dial_sequence('increment', 'normal'),
      'Increment',
    },
    ['<C-x>'] = {
      dial_sequence('decrement', 'normal'),
      'Decrement',
    },
  })
  whichkey.register({
    ['<C-a>'] = {
      dial_sequence('increment', 'visual'),
      'Increment',
    },
    ['<C-x>'] = {
      dial_sequence('decrement', 'visual'),
      'Decrement',
    },
    ['g<C-a>'] = {
      dial_sequence('increment', 'gvisual'),
      'Increment',
    },
    ['g<C-x>'] = {
      dial_sequence('decrement', 'gvisual'),
      'Decrement',
    },
  }, { mode = 'v' })
end
