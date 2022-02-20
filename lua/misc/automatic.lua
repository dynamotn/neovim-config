-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--      Automatic Group setting      --
---------------------------------------
local ex_cmd = vim.api.nvim_command    -- Execute Vim ex commands

local function create_augroups(definitions)
    for group_name, definition in pairs(definitions) do
        ex_cmd('augroup ' .. group_name)
        ex_cmd('autocmd!')
        for _, def in ipairs(definition) do
            local command = table.concat(vim.tbl_flatten{ 'autocmd', def }, ' ')
            ex_cmd(command)
        end
        ex_cmd('augroup END')
    end
end

create_augroups({
    reload_nvim_config = {
        { 'BufWritePost', [[$NVIMHOME/**/{*.vim,*.lua} nested source $MYVIMRC | redraw]] },
    },
    sync_plugin_list = {
        { 'BufWritePost', [[$NVIMHOME/lua/plugins/list.lua PackerSync]]},
    }
})
