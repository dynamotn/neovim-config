DEBUG = false
if vim.version().minor > 6 then
    require('core')
    require('plugins')
    require('misc')
else
    vim.notify('Requires neovim version 0.7+')
end
