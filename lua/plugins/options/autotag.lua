local present, autotag = pcall(require, 'nvim-ts-autotag')

if not present then
    return
end

require('nvim-treesitter.configs').setup({
    autotag = {
        enable = true,
    },
})
