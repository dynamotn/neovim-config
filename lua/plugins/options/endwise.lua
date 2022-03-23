local present, endwise = pcall(require, 'nvim-treesitter-endwise')

if not present then
    return
end

require('nvim-treesitter.configs').setup({
    endwise = {
        enable = true,
    },
})
