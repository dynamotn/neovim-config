DEBUG = true
if vim.fn.has('nvim-0.10.0') == 1 then
  require('core')
  require('misc')
  require('plugins')

  require('core.augroup').load_default_augroups()
  require('core.augroup').auto_install_ts_parser()
  require('core.augroup').auto_install_mason_tools()

  local root = require('util.root')
  vim.opt.rtp:append(root.get() .. "/.nvim")
else
  vim.notify('Requires neovim version 0.10+')
end
