--- External commands waited on where nothing else will do
---
--- Most commands run with a callback and never hold up the editor. A few
--- cannot: a file written through `BufWriteCmd`, a reply the language server
--- is waiting for, a plugin hook that has to answer now. Those wait here,
--- always with a deadline, and always hand back a result.
---
--- `vim.system():wait()` gives back nil, not a result, when the deadline
--- passes while something the command started still holds its output open --
--- a script running `sleep`, `sops` starting a `gpg-agent`. Reading `.code`
--- off that raises in the middle of a write or a server request.
local M = {}

--- The deadline when none is given, in milliseconds
M.TIMEOUT = 5000

--- The exit code `timeout(1)` and `vim.system` give a command run out of time
M.TIMED_OUT = 124

---@class DySyncOpts: vim.SystemOpts
---@field timeout? integer Milliseconds, `M.TIMEOUT` unless given

--- Run `cmd` and wait for it, for no longer than `opts.timeout`
---
--- A command that cannot start, or runs out of time, comes back as a failed
--- result -- `code` 127 or `M.TIMED_OUT`, the reason in `stderr` -- never as
--- an error. One started with `detach` leads a process group of its own, and
--- the whole group is killed on a timeout, so nothing it started is left
--- running.
---@param cmd string[]
---@param opts? DySyncOpts
---@return vim.SystemCompleted
function M.sync(cmd, opts)
  opts = vim.deepcopy(opts or {})
  local timeout = opts.timeout or M.TIMEOUT
  -- The deadline is the wait's: a `timeout` in the options as well would
  -- have the process killed and still leave the wait without a result
  opts.timeout = nil
  local started, obj = pcall(vim.system, cmd, opts)
  if not started then
    return { code = 127, signal = 0, stdout = '', stderr = tostring(obj) }
  end
  local ok, result = pcall(obj.wait, obj, timeout)
  if ok and result then return result end
  if opts.detach and obj.pid then pcall(vim.uv.kill, -obj.pid, 'sigkill') end
  return {
    code = M.TIMED_OUT,
    signal = 9,
    stdout = '',
    stderr = ok and ('timed out after %d ms'):format(timeout)
      or tostring(result),
  }
end

return M
