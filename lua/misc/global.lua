-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--      Useful global functions      --
---------------------------------------
------------------------------ }

-- Get dial group from buffer filetype {
_G.dynamo_dial_group = function()
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
------------------------------- }

-- Global command sequence when mapping key {
_G.dynamo_cmdcr = function(body)
  return '<cmd>' .. body .. '<CR>'
end
------------------------------------------- }

-- Whichkey mapping for filetypes {
_G.dynamo_whichkey = {}
--------------------------------- }

-- Check filetype is gotemplate {
_G.dynamo_gotemplate_detection = function(bufnr)
  local content = function()
    local content = vim.api.nvim_buf_get_lines(bufnr, 0, vim.api.nvim_buf_line_count(0), false)
    return table.concat(content, '\n')
  end
  if content():match('{{.+}}') then
    return 'gotmpl'
  end
end
------------------------------- }

-- Get foreground color from highlight group {
_G.dynamo_fg = function(name)
  local hl = vim.api.nvim_get_hl and vim.api.nvim_get_hl(0, { name = name }) or vim.api.nvim_get_hl_by_name(name, true)
  local fg = hl and hl.fg or hl.foreground
  return fg and string.format('#%06x', fg)
end
-------------------------------------------- }

-- Check plugin is declared in spec {
_G.dynamo_list_plugins = {}
_G.dynamo_has_plugin = function(plugin)
  return vim.list_contains(_G.dynamo_list_plugins, plugin)
end
----------------------------------- }
