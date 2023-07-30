DEBUG = true
if vim.fn.has('nvim-0.10.0') == 1 then
  require('core')
  require('misc')
  require('plugins')
else
  vim.notify('Requires neovim version 0.10+')
end
