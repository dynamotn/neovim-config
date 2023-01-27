local pretty_fold = require('pretty-fold')

pretty_fold.setup({
  keep_indentation = false,
  fill_char = '━',
  sections = {
    left = {
      '━ ',
      function()
        return string.rep('*', vim.v.foldlevel)
      end,
      ' ━┫',
      'content',
      '┣',
    },
    right = {
      '┫ ',
      'number_of_folded_lines',
      ' ┣━━',
    },
  },
})
require('fold-preview').setup({
  border = 'rounded',
})
