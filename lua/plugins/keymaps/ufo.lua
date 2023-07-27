local ufo = require('ufo')

return {
  {
    'zR',
    function()
      ufo.openAllFolds()
    end,
    desc = 'Open all folds',
  },
  {
    'zM',
    function()
      ufo.closeAllFolds()
    end,
    desc = 'Close all folds',
  },
}
