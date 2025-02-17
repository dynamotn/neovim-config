local rainbow = require('rainbow-delimiters')

vim.g.rainbow_delimiters = {
  strategy = {
    [''] = rainbow.strategy['global'],
    vim = rainbow.strategy['local'],
  },
  query = {
    [''] = 'rainbow-delimiters',
  },
  log = {
    level = vim.log.levels.TRACE,
  },
}
