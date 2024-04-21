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

-- Check if Neovim is opened to show something
M.is_something_shown = function()
  -- - Current buffer has any lines (something opened explicitly).
  -- NOTE: Usage of `line2byte(line('$') + 1) > 0` seemed to be fine, but it
  -- doesn't work if some automated changed was made to buffer while leaving it
  -- empty (returns 2 instead of -1). This was also the reason of not being
  -- able to test with child Neovim process from 'tests/helpers'.
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  if #lines > 1 or (#lines == 1 and lines[1]:len() > 0) then
    return true
  end

  -- - Several buffers are listed (like session with placeholder buffers). That
  --   means unlisted buffers (like from `nvim-tree`) don't affect decision.
  local listed_buffers = vim.tbl_filter(function(buf_id)
    return vim.fn.buflisted(buf_id) == 1
  end, vim.api.nvim_list_bufs())
  if #listed_buffers > 1 then
    return true
  end

  -- - There are files in arguments (like `nvim foo.txt` with new file).
  if vim.fn.argc() > 0 then
    return true
  end

  return false
end

return M
