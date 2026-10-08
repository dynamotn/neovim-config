--- Open a Snacks picker at the project root of the buffer, unless told
--- otherwise. `require('util.pick')(command, opts)` is `wrap()`: a function to
--- hand a key spec.
---@class util.pick
---@overload fun(command?: string, opts?: util.pick.Opts): fun()
local M = setmetatable({}, {
  __call = function(m, ...) return m.wrap(...) end,
})

---@class util.pick.Opts: snacks.picker.Config
---@field root? boolean Start at the root of `buf` (default) or the cwd
---@field cwd? string
---@field buf? number

--- Generic names, so a caller does not have to know Snacks' own
M.commands = {
  files = 'files',
  live_grep = 'grep',
  oldfiles = 'recent',
}

---@param command? string
---@param opts? util.pick.Opts
function M.open(command, opts)
  command = (command == nil or command == 'auto') and 'files' or command
  opts = vim.deepcopy(opts or {})

  if type(opts.cwd) == 'boolean' then
    require('util.plugin').warn('util.pick: opts.cwd should be a string or nil')
    opts.cwd = nil
  end

  if not opts.cwd and opts.root ~= false then
    opts.cwd = require('util.root').get({ buf = opts.buf })
  end

  return Snacks.picker.pick(M.commands[command] or command, opts)
end

---@param command? string
---@param opts? util.pick.Opts
---@return fun()
function M.wrap(command, opts)
  opts = opts or {}
  return function() M.open(command, vim.deepcopy(opts)) end
end

--- Files of this configuration
---@return fun()
function M.config_files()
  return M.wrap('files', { cwd = vim.fn.stdpath('config') })
end

return M
