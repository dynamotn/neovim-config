local extras = require('util.extras')

return {
  { '<F12>', extras.cmdcr('GkeepEnter menu right'), desc = 'Google Keep' },
  { '<Space>un', extras.cmdcr('GkeepNew neorg'), desc = 'New Neorg note' },
  {
    '<Space>ul',
    extras.cmdcr('GkeepNew list'),
    desc = 'New Google Keep list',
  },
}
