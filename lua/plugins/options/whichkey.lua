local whichkey = require('which-key')

whichkey.setup({
  icons = {
    breadcrumn = '»',
    separator = '→',
    group = '⍟ ',
  },
  win = {
    border = 'single',
  },
  layout = {
    align = 'center',
  },
  show_help = false,
  show_keys = false,
})
