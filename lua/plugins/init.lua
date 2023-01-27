-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--      Plugin initialization        --
---------------------------------------
local g = vim.g -- Global variables

local present, lazy = pcall(require, 'lazy')
if not present then
  return
end

local register_config = require('plugins.register').register_config
local register_setup = require('plugins.register').register_setup
local register_keymaps = require('plugins.register').register_keymaps

-- Read the list plugins file
local common_list = require('plugins.list')
local per_language_list = require('languages').get_plugins()
local final_list = {}

for _, plugin in pairs(common_list) do
  if plugin.name then
    table.insert(
      final_list,
      vim.tbl_extend('force', plugin, {
        config = register_config,
        init = register_setup,
        keys = register_keymaps,
      })
    )
  else
    table.insert(final_list, plugin)
  end
end

for _, plugin in pairs(per_language_list) do
  if plugin.name then
    table.insert(
      final_list,
      vim.tbl_extend('force', plugin, {
        config = register_config,
        init = register_setup,
        keys = register_keymaps,
      })
    )
  else
    table.insert(final_list, plugin)
  end
end

return lazy.setup(final_list, {
  defaults = {
    lazy = true,
  },
})
