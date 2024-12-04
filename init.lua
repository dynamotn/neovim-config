DEBUG = false
FULL = false
ENABLE_OTTER = false
if vim.fn.has('nvim-0.10.0') == 1 then
  require('core')
  pcall(require, 'per_machine')
  require('plugins')

  require('core.augroup').setup()
else
  vim.notify('Requires neovim version 0.10+')
end
