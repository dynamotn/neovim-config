-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--      Automatic Group setting      --
---------------------------------------
local ex_cmd = vim.api.nvim_command -- Execute Vim ex commands
local M = {}

M.create_augroups = function(definitions, is_buffer)
    for group_name, definition in pairs(definitions) do
        ex_cmd('augroup ' .. group_name)
        if is_buffer then
            ex_cmd('autocmd! * <buffer>')
        else
            ex_cmd('autocmd!')
        end
        for _, def in ipairs(definition) do
            local command = table.concat(vim.tbl_flatten({ 'autocmd', def }), ' ')
            ex_cmd(command)
        end
        ex_cmd('augroup END')
    end
end

M.delete_augroups = function(name)
    vim.schedule(function()
        if vim.fn.exists('#' .. name) == 1 then
            vim.cmd('augroup ' .. name)
            vim.cmd('autocmd!')
            vim.cmd('augroup END')
        end
    end)
end

M.load_default_augroups = function()
    local present, path = pcall(require, 'plenary.path')

    if not present then
        return
    end

    local config_path = path:new():absolute()

    M.create_augroups({
        sync_plugin_list = {
            { 'BufWritePost', config_path .. 'lua/plugins/list.lua', 'lua dynamo_reload_nvim_config(true)' },
        },
        -- reload_nvim_config = {
        --     { 'BufWritePost', config_path .. '**/{*.vim,*.lua}', 'lua dynamo_reload_nvim_config()' },
        -- },
        quick_quit_manual = {
            { 'FileType', 'qf,help,man,lspinfo,lsp-installer', 'nnoremap <silent> <buffer> q :close<CR>' },
        },
    })

    M.create_augroups({
        basic_lsp = {
            { 'CursorHold', '<buffer>', 'lua vim.lsp.buf.hover()' },
            { 'CursorMoved', '<buffer>', 'lua vim.lsp.buf.clear_references()' },
        },
    }, true)
end

M.enable_linter = function()
    local present, _ = pcall(require, 'lint')
    if not present then
        return
    end

    M.create_augroups({
        linter = {
            { 'BufWritePost,BufRead,BufNewFile', '<buffer>', [[lua require('lint').try_lint()]] },
        },
    }, true)
end

M.enable_highlight_document = function(client_id)
    M.create_augroups({
        highlight_lsp = {
            { 'CursorHold', '<buffer>', string.format('lua dynamo_lsp_document_highlight(%d)', client_id) },
        },
    }, true)
end

M.disable_highlight_document = function()
    M.delete_augroups('highlight_lsp')
end

M.enable_codelens = function(client_id)
    M.create_augroups({
        codelens_lsp = {
            { 'InsertLeave', '<buffer>', string.format('lua dynamo_lsp_codelens(%d)', client_id) },
        },
    }, true)
end

M.disable_codelens = function()
    M.delete_augroups('codelens_lsp')
end

return M
