local M = {}

-- Get foreground color from highlight group
M.fg = function(name)
  local hl = vim.api.nvim_get_hl and vim.api.nvim_get_hl(0, { name = name }) or vim.api.nvim_get_hl_by_name(name, true)
  local fg = hl and hl.fg or hl.foreground
  return fg and string.format('#%06x', fg)
end

-- Global command sequence when mapping key
M.cmdcr = function(body)
  return '<cmd>' .. body .. '<CR>'
end

-- Get dial group from buffer filetype
M.get_dial_group = function()
  local present, dial = pcall(require, 'dial.config')
  if not present then
    return 'default'
  end
  local language = require('languages').get_language_from_filetype(vim.bo.filetype)

  if dial.augends:get(language) then
    return language
  end
  return 'default'
end

-- Check if plugin is declared in spec
M.has_plugin = function(plugin)
  return vim.list_contains(_G.dynamo_list_plugins, plugin)
end

return M
