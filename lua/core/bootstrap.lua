-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--   General Neovim bootstrapping    --
---------------------------------------
local g = vim.g -- Global variables

---------- Lazy ----------- {
local lazy_path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazy_path) then
  print('Cloning lazy..')
  -- Remove the dir before cloning
  vim.fn.delete(lazy_path, 'rf')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim',
    '--depth',
    '1',
    lazy_path,
  })

  vim.opt.rtp:prepend(lazy_path)
  local present, lazy = pcall(require, 'lazy')

  if present then
    print('Lazy cloned successfully.')
    g.dynamo_bootstrap_lazy = true
  else
    error("Couldn't clone lazy !\nLazy path: " .. lazy_path .. '\n' .. lazy)
  end
else
  vim.opt.rtp:prepend(lazy_path)
end
----------------------------- }

-- Disable builtin plugins -- {
-- See in https://github.com/neovim/neovim/tree/master/runtime/plugin
local unwanted_plugins = {
  '2html_plugin',
  'gzip',
  'matchit',
  'netrwPlugin',
  'tarPlugin',
  'tutor_mode_plugin',
  'zipPlugin',
}
for _, plugin in pairs(unwanted_plugins) do
  g['loaded_' .. plugin] = 1
end
----------------------------- }
