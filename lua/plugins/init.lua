-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--      Plugin initialization        --
---------------------------------------
local g = vim.g -- Global variables

local present, lazy = pcall(require, 'lazy')
if not present then
  return
end

local register_options = require('plugins.register').register_options
local register_setup = require('plugins.register').register_setup
local register_keymaps = require('plugins.register').register_keymaps

-- Read the list plugins file
local common_list = require('plugins.list')
local per_language_list = require('languages').get_plugins()
local final_list = {}

-- Automatically inject config, setup, keymaps of plugin
-- when lazy-loading with Lazy. Plugin must have name then trigger that.
local function inject_lazy(plugin)
  local result = nil
  if plugin.name then
    -- Inject to dependencies
    local dependencies = {}
    if plugin.dependencies then
      for _, dependency in pairs(plugin.dependencies) do
        table.insert(dependencies, inject_lazy(dependency))
      end
    end

    result = vim.tbl_extend('force', plugin, {
      config = register_options,
      init = register_setup,
      keys = register_keymaps,
      dependencies = dependencies,
    })
  else
    result = plugin
  end
  return result
end

-- Add plugin from common list to lazy
for _, plugin in pairs(common_list) do
  table.insert(final_list, inject_lazy(plugin))
end

-- Add plugin from specific language's list to lazy
for _, plugin in pairs(per_language_list) do
  table.insert(final_list, inject_lazy(plugin))
end

return lazy.setup(final_list, {
  defaults = {
    lazy = true,
  },
})
