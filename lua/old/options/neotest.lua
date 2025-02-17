local neotest = require('neotest')
local adapters = require('languages').setup_test()

local present, vimtest = pcall(require, 'neotest-vim-test')
if present then
  table.insert(
    adapters,
    vimtest({
      ignore_file_types = {},
    })
  )
end

local neotest_ns = vim.api.nvim_create_namespace('neotest')
vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
      return message
    end,
  },
}, neotest_ns)

neotest.setup({
  adapters = adapters,
  status = { virtual_text = true },
  output = { open_on_run = true },
})
