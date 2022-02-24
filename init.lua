vim.api.nvim_command([[let $NVIMHOME=fnamemodify(expand('<sfile>'), ':h')]])

require('core')
require('plugins')
require('misc')
