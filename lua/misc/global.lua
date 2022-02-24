-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--      Useful global functions      --
---------------------------------------

-- Reload neovim configuration {
_G.dynamo_reload_nvim_config = function(has_changed_plugins)
    for name, _ in pairs(package.loaded) do
        if name:match('^core') or name:match('^lsp') or name:match('^plugins') then
            package.loaded[name] = nil
        end
    end

    dofile(vim.env.MYVIMRC)
    vim.notify('Nvim configuration reloaded!', vim.log.levels.WARNING)

    if has_changed_plugins then
        vim.api.nvim_command('redraw')
        require('packer').sync()
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
