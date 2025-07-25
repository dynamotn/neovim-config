---@class D2Options
---@field theme_id? number
---@field dark_theme_id? number
---@field scale? number
---@field layout? string
---@field sketch? boolean

---@type table<string, string>

---@class Renderer<D2Options>
local M = {
  id = 'd2_file',
}

-- fs cache
local cache_dir = vim.fn.resolve(vim.fn.stdpath('cache') .. '/diagram-cache/d2')
vim.fn.mkdir(cache_dir, 'p')

---@param source string
---@param options D2Options
---@return table|nil
M.render = function(source, options)
  local hash = vim.fn.sha256(
    M.id .. ':' .. source .. ':' .. vim.uv.fs_stat(source).mtime.sec
  )

  local path = vim.fn.resolve(cache_dir .. '/' .. hash .. '.png')
  if vim.fn.filereadable(path) == 1 then return { file_path = path } end

  if not vim.fn.executable('d2') then
    error('diagram/d2: d2 not found in PATH')
  end

  local command_parts = {
    'd2',
    source,
    path,
  }
  if options.theme_id then
    table.insert(command_parts, '-t')
    table.insert(command_parts, options.theme_id)
  end
  if options.dark_theme_id then
    table.insert(command_parts, '--dark-theme')
    table.insert(command_parts, options.dark_theme_id)
  end
  if options.scale then
    table.insert(command_parts, '--scale')
    table.insert(command_parts, options.scale)
  end
  if options.layout then
    table.insert(command_parts, '--layout')
    table.insert(command_parts, options.layout)
  end
  if options.sketch then table.insert(command_parts, '-s') end

  local command = table.concat(command_parts, ' ')

  local job_id = vim.fn.jobstart(command, {
    on_stdout = function(job_id, data, event) end,
    on_stderr = function(job_id, data, event)
      -- local error_msg = table.concat(data, '\n')
      -- vim.notify(
      --   'diagram/d2: d2 failed to render diagram\n' .. error_msg,
      --   vim.log.levels.ERROR
      -- )
      -- return nil
    end,
    on_exit = function(job_id, exit_code, event)
      -- local msg =
      --   string.format('Job %d exited with code %d.', job_id, exit_code)
      -- vim.notify(msg, vim.log.levels.INFO)
    end,
  })

  return { file_path = path, job_id = job_id }
end

return M
