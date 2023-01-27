local neotest = require('neotest')

local adapters = {}

local present, neotest_vim = pcall(require, 'neotest-vim-test')
if present then
  table.insert(
    adapters,
    neotest_vim({
      ignore_file_types = {},
    })
  )
end

neotest.setup({
  adapters = adapters,
})
