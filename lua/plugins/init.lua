-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--      Plugin initialization        --
---------------------------------------
local g = vim.g -- Global variables

local present, lazy = pcall(require, 'lazy')
if not present then
  return
end

-- Read the list plugins file
local list = require('plugins.list')
local per_language_list = require('languages').get_plugins()

return lazy.setup({
  list,
  per_language_list,
}, {
  defaults = {
    lazy = true,
  },
})
