vim.api.nvim_command([[let $NVIMHOME=fnamemodify(expand('<sfile>'), ':h')]])

local core_modules = {
    'options',
    'keymaps',
    'bootstrap',
}

for _, module in ipairs(core_modules) do
    local ok, err = pcall(require, 'core.' .. module)
    if not ok then
        error('Error loading core.' .. module .. '\n\n' .. err)
    end
end

require('plugins')
require('misc.automatic')
