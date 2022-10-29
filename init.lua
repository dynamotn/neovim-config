DEBUG = false
if vim.version().minor > 6 then
  vim.g.did_load_filetypes = 1
  require('core')
  require('misc')
  require('plugins')
  require('lsp')
else
  vim.notify('Requires neovim version 0.7+')
end
