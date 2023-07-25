local neotree = require('neo-tree')

neotree.setup({
  open_files_do_not_replace_types = {
    'terminal',
    'Trouble',
    'qf',
    'sagaoutline',
    'edgy',
  },
  filesystem = {
    hijack_netrw_behavior = 'open_current',
  },
})
