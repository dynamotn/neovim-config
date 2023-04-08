DEBUG = false
if vim.version().minor >= 10 then
  require('core')
  require('misc')
  require('plugins')
else
  vim.notify('Requires neovim version 0.10+')
end
