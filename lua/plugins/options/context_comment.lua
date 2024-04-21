require('ts_context_commentstring').setup({
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
})

require('mini.comment').setup({
  hooks = {
    pre = function()
      require('ts_context_commentstring.internal').update_commentstring()
    end,
  },
})
