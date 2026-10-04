-- Bootstrap for the unit tests: this repository and the few plugins the
-- modules under test lean on, and nothing else of the configuration.
--
-- The specs require modules one at a time and stub what they reach for, so
-- neither LazyVim nor the plugin specs are loaded. Plenary (the test runner)
-- and LazyVim (whose `LazyVim.*` helpers a few modules call) are taken from
-- lazy.nvim's install directory when the configuration has been started once
-- on this machine, and cloned next to the tests otherwise.
--
--   nvim --headless --noplugin -u tests/minimal_init.lua \
--     -c "PlenaryBustedDirectory tests/spec {minimal_init = 'tests/minimal_init.lua'}"

local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2)))
root = vim.fs.normalize(vim.fn.fnamemodify(root, ':p'))

---@param name string Directory name under lazy.nvim's root
---@param url string Where to clone it from when it is missing
---@return string
local function dependency(name, url)
  local installed =
    vim.fs.joinpath(vim.fn.stdpath('data') --[[@as string]], 'lazy', name)
  if vim.uv.fs_stat(installed) then return installed end
  local local_copy = vim.fs.joinpath(root, '.tests', name)
  if not vim.uv.fs_stat(local_copy) then
    local out = vim.fn.system({
      'git',
      'clone',
      '--depth=1',
      '--filter=blob:none',
      url,
      local_copy,
    })
    if vim.v.shell_error ~= 0 then
      io.stderr:write('minimal_init: failed to clone ' .. url .. '\n' .. out)
      os.exit(1)
    end
  end
  return local_copy
end

-- A git hook runs with `GIT_DIR`, `GIT_INDEX_FILE` and the like pointing at
-- the repository being committed to. Left in place, a spec that runs git in a
-- scratch directory -- `git init` there -- acts on that repository instead.
for _, name in
  ipairs(vim.fn.systemlist({ 'git', 'rev-parse', '--local-env-vars' }))
do
  vim.env[name] = nil
end

vim.opt.runtimepath = {
  root,
  dependency('plenary.nvim', 'https://github.com/nvim-lua/plenary.nvim'),
  dependency('LazyVim', 'https://github.com/LazyVim/LazyVim'),
  -- `lazyvim.util` requires `lazy.core.util` as it loads
  dependency('lazy.nvim', 'https://github.com/folke/lazy.nvim'),
  vim.env.VIMRUNTIME,
}
vim.opt.packpath = {}
vim.opt.swapfile = false
vim.opt.shadafile = 'NONE'

-- Specs live outside `lua/`, so their shared helpers are found by path.
package.path = vim.fs.joinpath(root, 'tests', '?.lua') .. ';' .. package.path

vim.cmd.runtime({ 'plugin/plenary.vim', bang = true })
