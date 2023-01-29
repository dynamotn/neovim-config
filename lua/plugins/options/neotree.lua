local neotree = require('neo-tree')

neotree.setup({
  filesystem = {
    hijack_netrw_behavior = 'open_current',
  },
})
