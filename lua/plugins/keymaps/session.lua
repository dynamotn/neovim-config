local extras = require('util.extras')

return {
  {
    '<Space>sa',
    extras.cmdcr('Telescope persisted'),
    desc = 'List all session',
  },
  {
    '<Space>ss',
    function()
      require('persisted').save()
    end,
    desc = 'Save current session',
  },
  {
    '<Space>sl',
    function()
      require('persisted').load({ last = true })
    end,
    desc = 'Load last session',
  },
}
