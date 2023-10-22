local extras = require('util.extras')

return {
  ['<Space>lc'] = {
    extras.cmdcr('lua require("rest-nvim").run()'),
    'Run current HTTP request',
  },
}
