local flash = require('flash')

flash.setup({
  search = {
    mode = 'fuzzy',
  },
  modes = {
    char = {
      jump_labels = true,
    },
  },
})
