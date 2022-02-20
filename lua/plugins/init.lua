-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--      Plugin initialization        --
---------------------------------------
vim.cmd[[packadd packer.nvim]]
local g = vim.g                             -- Global variables

local present, packer = pcall(require, 'packer')
if not present then
  return
end

-- Read the list plugins file
local list = require('plugins.list')

return packer.startup({function(use)
    -- Automatically reload config when update plugin
    vim.cmd[[autocmd User PackerComplete source $MYVIMRC]]

    for _, v in pairs(list) do
        use(v)
    end

    -- Automatically fire sync package when first time Packer is installed
    if g.dynamo_bootstrap_packer then
        packer.sync()
    end
end,
config = {
    auto_clean = true,
    compile_on_sync = true,
    display = {
        open_fn = function()
            return require('packer.util').float { border = 'single' }
        end,
        prompt_border = 'single',
    },
}})
