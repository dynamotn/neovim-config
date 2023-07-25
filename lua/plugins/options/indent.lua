local indent = require('indent_blankline')

indent.setup({
  char = '▏',
  show_current_context = true,
  show_trailing_blankline_indent = false,
  filetype_exclude = {
    'help',
    'neo-tree',
    'Trouble',
    'lazy',
    'mason',
    'notify',
    'toggleterm',
    'dbout',
  },
})
