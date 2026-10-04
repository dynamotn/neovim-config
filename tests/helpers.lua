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

--- Drop `modules` from `package.loaded`, so the next `require` reads them anew
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

--- Load LazyVim's helpers as the `LazyVim` global, as lazy.nvim would
M.lazyvim = function()
  _G.LazyVim = _G.LazyVim or require('lazyvim.util')
  return _G.LazyVim
end

--- Load `config.globals` the way `init.lua` does, without a `per_machine`
M.globals = function()
  M.unload('config.globals', 'config.languages')
  require('config.globals')
end

return M
