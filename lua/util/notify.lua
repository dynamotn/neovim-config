--- Notifications of DyNeo, titled after the part that sends them
---
--- Every tool says who is talking the same way: `DyNeo Kubernetes`,
--- `DyNeo Runbook`. `vim.notify` itself, so noice and the history get them,
--- and nothing of lazy.nvim, so a tool can notify under `nvim --clean` too.
local M = {}

--- The title of `area`'s notifications
---@param area? string
---@return string
function M.title(area) return area and ('DyNeo ' .. area) or 'DyNeo' end

--- `vim.notify` for `area`: `INFO` unless a level is given
---@param area? string
---@return fun(msg: string, level?: integer, opts?: table)
function M.titled(area)
  local title = M.title(area)
  return function(msg, level, opts)
    vim.notify(
      msg,
      level or vim.log.levels.INFO,
      vim.tbl_extend('force', opts or {}, { title = title })
    )
  end
end

return M
