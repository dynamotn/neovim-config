-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--      Automatic Group setting      --
---------------------------------------
local ex_cmd = vim.api.nvim_command -- Execute Vim ex commands

local function create_augroups(definitions)
    for group_name, definition in pairs(definitions) do
        ex_cmd('augroup ' .. group_name)
        ex_cmd('autocmd!')
        for _, def in ipairs(definition) do
            local command = table.concat(vim.tbl_flatten({ 'autocmd', def }), ' ')
            ex_cmd(command)
        end
        ex_cmd('augroup END')
    end
end

function _G.reload_nvim_config(has_changed_plugins)
    for name, _ in pairs(package.loaded) do
        if name:match('^core') or name:match('^lsp') or name:match('^plugins') then
            package.loaded[name] = nil
        end
    end

    dofile(vim.env.MYVIMRC)
    vim.notify('Nvim configuration reloaded!', vim.log.levels.INFO)

    if has_changed_plugins then
        ex_cmd('redraw')
        require('packer').sync()
    end
end

create_augroups({
    reload_nvim_config = {
        { 'BufWritePost', '$NVIMHOME/**/{*.vim,*.lua}', 'lua reload_nvim_config()' },
    },
    sync_plugin_list = {
        { 'BufWritePost', '$NVIMHOME/lua/plugins/list.lua', 'lua reload_nvim_config(true)' },
    },
})
