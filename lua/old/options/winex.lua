vim.o.winwidth = 10
vim.o.winminwidth = 10
vim.o.equalalways = false

local winex = require('windows')
winex.setup({
  animation = { enable = true, duration = 150 },
})
