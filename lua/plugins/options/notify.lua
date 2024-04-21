local notify = require('notify')

notify.setup({
  stages = "static",
  timeout = 3000,
  max_height = function()
    return math.floor(vim.o.lines * 0.75)
  end,
  max_width = function()
    return math.floor(vim.o.columns * 0.75)
  end,
  background_colour = '#000000',
  on_open = function(win)
    vim.api.nvim_win_set_config(win, { zindex = 100 })
  end,
})
