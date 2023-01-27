vim.ui.select = function(...)
  require('lazy').load({ plugins = { 'dressing' } })
  return vim.ui.select(...)
end
vim.ui.input = function(...)
  require('lazy').load({ plugins = { 'dressing' } })
  return vim.ui.input(...)
end
