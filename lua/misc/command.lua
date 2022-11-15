---------------------------------------
--       Self-defined command        --
---------------------------------------

local ex_cmd = vim.api.nvim_command -- Execute Vim ex commands
local M = {}

--- Create self-defined command
---@param name string Name of command to call
---@param definition string Command to call
---@param args string Arguments of command, see :command-nargs
---@param address string Range handling, default is `lines`, see :command-addr
---@param complete string Completion behavior, see :command-complete
M.create_command = function(name, definition, args, address, complete)
  args = args or 0
  address = address or 'lines'
  if complete ~= nil then
    complete = '-complete=' .. complete
  else
    complete = ''
  end
  ex_cmd('command! -nargs=' .. args .. ' -addr=' .. address .. ' ' .. complete .. ' ' .. name .. ' ' .. definition)
end

M.start = function()
  M.create_command('SqlsEditConnections', 'split ~/.config/sqls/config.yml')
end

return M
