DEBUG = false
FULL = false
ENABLED_OTTER = true
if vim.fn.has('nvim-0.10.0') == 1 then
  require('core')
  pcall(require, 'per_machine')
  require('plugins')

  require('core.augroup').setup()
else
  vim.notify('Requires neovim version 0.10+')
end
