-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--   General Neovim bootstrapping    --
---------------------------------------
local g = vim.g -- Global variables

---------- Packer ----------- {
local packer_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
    print('Cloning packer..')
    -- Remove the dir before cloning
    vim.fn.delete(packer_path, 'rf')
    vim.fn.system({
        'git',
        'clone',
        'https://github.com/wbthomason/packer.nvim',
        '--depth',
        '1',
        packer_path,
    })

    vim.cmd([[packadd packer.nvim]])
    present, packer = pcall(require, 'packer')

    if present then
        print('Packer cloned successfully.')
        g.dynamo_bootstrap_packer = true
    else
        error("Couldn't clone packer !\nPacker path: " .. packer_path .. '\n' .. packer)
    end
end
----------------------------- }

-- Disable builtin plugins -- {
-- See in https://github.com/neovim/neovim/tree/master/runtime/plugin
local unwanted_plugins = {
    '2html_plugin',
    'gzip',
    'matchit',
    'netrwPlugin',
    'tarPlugin',
    'tutor_mode_plugin',
    'zipPlugin',
}
for _, plugin in pairs(unwanted_plugins) do
    g['loaded_' .. plugin] = 1
end
----------------------------- }
