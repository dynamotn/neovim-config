--- Shared helpers for the specs under `tests/spec`
local M = {}

--- Absolute path of this repository
M.root = vim.fs
  .normalize(
    vim.fn.fnamemodify(
      vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2))),
      ':p'
    )
  )
  :gsub('/$', '')

--- Drop the named modules from `package.loaded`, so the next `require` reads
--- them anew
---@param ... string Module names
M.unload = function(...)
  for _, name in ipairs({ ... }) do
    package.loaded[name] = nil
  end
end

--- Replace `tbl[key]` with `value` and return a function putting it back
---@param tbl table
---@param key any
---@param value any
---@return fun()
M.stub = function(tbl, key, value)
  local original = rawget(tbl, key)
  tbl[key] = value
  return function() tbl[key] = original end
end

--- A stand-in for `vim.system`, to `stub` in its place
---
--- `reply(cmd, opts)` gives the result. Its output reaches the readers the
--- caller gave, the way `vim.system` streams it, and the exit callback gets
--- what is left, so `util.system.run` and plain callers both read it.
---@param reply fun(cmd: string[], opts: table): table?
---@return fun(cmd: string[], opts?: table, on_exit?: fun(result: table)): table
M.system_double = function(reply)
  return function(cmd, opts, on_exit)
    opts = opts or {}
    local result = vim.tbl_extend(
      'keep',
      vim.deepcopy(reply(cmd, opts) or {}),
      { code = 0, signal = 0 }
    )
    for _, stream in ipairs({ 'stdout', 'stderr' }) do
      if type(opts[stream]) == 'function' then
        if result[stream] then opts[stream](nil, result[stream]) end
        opts[stream](nil, nil)
        result[stream] = nil
      end
    end
    if on_exit then on_exit(result) end
    return {
      kill = function() end,
      wait = function() return result end,
    }
  end
end

--- Make a scratch directory, removed by the returned function
---@return string path
---@return fun() cleanup
M.tmpdir = function()
  local path = vim.fn.tempname()
  vim.fn.mkdir(path, 'p')
  path = vim.uv.fs_realpath(path) or path
  return path, function() vim.fn.delete(path, 'rf') end
end

--- Write `lines` to `path`, creating its parent directories
---@param path string
---@param lines? string[]
M.write = function(path, lines)
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  vim.fn.writefile(lines or {}, path)
end

--- Make a scratch buffer holding `lines`, optionally named and typed
---@param opts? { name?: string, filetype?: string, lines?: string[] }
---@return integer bufnr
M.buffer = function(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_create_buf(true, false)
  if opts.name then vim.api.nvim_buf_set_name(bufnr, opts.name) end
  if opts.lines then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, opts.lines)
  end
  if opts.filetype then vim.bo[bufnr].filetype = opts.filetype end
  return bufnr
end

--- Load `config.globals` the way `init.lua` does, without a `per_machine`
M.globals = function()
  M.unload('config.globals', 'config.languages')
  require('config.globals')
end

return M
