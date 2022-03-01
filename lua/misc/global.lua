-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--      Useful global functions      --
---------------------------------------

-- Unload neovim module {
_G.dynamo_unload_module = function(module_name, reload)
    reload = reload or false

    for name, _ in pairs(package.loaded) do
        if name:match('^' .. module_name) then
            package.loaded[name] = nil
        end
    end

    if reload then
        require(module_name)
    end
end
-- }

-- Reload neovim configuration {
_G.dynamo_reload_nvim_config = function(has_changed_plugins)
    dynamo_unload_module('core', true)
    dynamo_unload_module('plugins', true)
    dynamo_unload_module('misc', true)
    dynamo_unload_module('languages', true)

    dofile(vim.env.MYVIMRC)
    vim.notify('Nvim configuration reloaded!', vim.log.levels.WARNING)

    if has_changed_plugins then
        require('packer').sync()
        vim.api.nvim_command('redraw')
    end
end
------------------------------ }

-- Mapping for Enter key in edit mode {
_G.dynamo_mapping_enter = function()
    local autopairs = require('nvim-autopairs')
    if vim.fn.pumvisible() ~= 0 then
        if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
            return autopairs.esc('<C-y>')
        else
            return autopairs.esc('<C-e>') .. autopairs.autopairs_cr()
        end
    else
        return autopairs.autopairs_cr()
    end
end
------------------------------------- }

-- Mapping for Backspace key in edit mode {
_G.dynamo_mapping_backspace = function()
    local autopairs = require('nvim-autopairs')
    if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ 'mode' }).mode == 'eval' then
        return autopairs.esc('<C-e>') .. autopairs.autopairs_bs()
    else
        return autopairs.autopairs_bs()
    end
end
----------------------------------------- }
