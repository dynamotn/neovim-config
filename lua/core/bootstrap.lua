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
