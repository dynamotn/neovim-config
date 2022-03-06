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

local present, path = pcall(require, 'plenary.path')

if not present then
    return
end

local config_path = path:new():absolute()

local augroup_list = {
    sync_plugin_list = {
        { 'BufWritePost', config_path .. 'lua/plugins/list.lua', 'lua dynamo_reload_nvim_config(true)' },
    },
    -- reload_nvim_config = {
    --     { 'BufWritePost', config_path .. '**/{*.vim,*.lua}', 'lua dynamo_reload_nvim_config()' },
    -- },
}

local present, _ = pcall(require, 'lint')
if present then
    augroup_list['linter'] = {
        { 'BufWritePost,BufRead,BufNewFile', '<buffer>', [[lua require('lint').try_lint()]] },
    }
end

create_augroups(augroup_list)
