local whichkey = require('which-key')

whichkey.setup({
  key_labels = {
    ['<space>'] = '<Space>',
    ['<cr>'] = '<⏎>',
    ['<tab>'] = '<Tab>',
    ['<leader>'] = '<Leader>',
  },
  icons = {
    breadcrumn = '»',
    separator = '→',
    group = '⍟ ',
  },
  window = {
    border = 'single',
  },
  layout = {
    align = 'center',
  },
  show_help = false,
  show_keys = false,
})
