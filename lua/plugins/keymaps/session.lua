local session = require('persisted')
local present, telescope = pcall(require, 'telescope')

return {
  present and {
    '<Space>sa',
    dynamo_cmdcr('Telescope persisted'),
    desc = 'List all session',
  } or nil,
  {
    '<Space>ss',
    function()
      session.save()
    end,
    desc = 'Save current session',
  },
  {
    '<Space>sl',
    function()
      session.load({ last = true })
    end,
    desc = 'Load last session',
  },
}
