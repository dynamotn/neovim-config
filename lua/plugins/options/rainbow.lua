local present, rainbow = pcall(require, 'rainbow')

if not present then
    return
end

require('nvim-treesitter.configs').setup({
    rainbow = {
        enable = true,
        extended_mode = true,
    },
})
