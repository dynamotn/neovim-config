vim.api.nvim_command([[let $NVIMHOME=fnamemodify(expand('<sfile>'), ':h')]])

local core_modules = {
    'bootstrap',
    'options',
    'keymaps',
}

for _, module in ipairs(core_modules) do
    local ok, err = pcall(require, 'core.' .. module)
    if not ok then
        error('Error loading core.' .. module .. '\n\n' .. err)
    end
end

require('plugins')

local misc_modules = {
    'automatic',
    'completion',
}

for _, module in ipairs(misc_modules) do
    local ok, err = pcall(require, 'misc.' .. module)
    if not ok then
        error('Error loading misc.' .. module .. '\n\n' .. err)
    end
end
