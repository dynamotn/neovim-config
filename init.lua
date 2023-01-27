DEBUG = false
if vim.version().minor > 6 then
  require('core')
  require('misc')
  require('plugins')
else
  vim.notify('Requires neovim version 0.8+')
end
