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
  local hash
  if not vim.uv.fs_stat(source) then
    hash = vim.fn.sha256(M.id .. ':' .. source)
  else
    hash = vim.fn.sha256(
      M.id .. ':' .. source .. ':' .. vim.uv.fs_stat(source).mtime.sec
    )
  end

  local path = vim.fn.resolve(cache_dir .. '/' .. hash .. '.png')
  if vim.fn.filereadable(path) == 1 then return { file_path = path } end

  if not vim.fn.executable('d2') then
    vim.notify('[diagram/d2] d2 not found in PATH', vim.log.levels.ERROR)
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

  local stdout, stderr, exit_code = {}, {}, nil
  local job_id = vim.fn.jobstart(command, {
    on_stdout = function(_, data, _)
      data = table.concat(data, '\n')
      if #data > 0 then stdout[#stdout + 1] = data end
    end,
    on_stderr = function(_, data, _)
      stderr[#stderr + 1] = table.concat(data, '\n')
    end,
    on_exit = function(_, code, _) exit_code = code end,
    stdout_buffered = true,
    stderr_buffered = true,
  })

  if exit_code ~= nil then
    vim.notify(
      ('[diagram/d2] failed to render with code %s:\n%s\n%s'):format(
        exit_code,
        command,
        table.concat(stderr, '')
      ),
      vim.log.levels.ERROR
    )
  end

  return { file_path = path, job_id = job_id }
end

return M
