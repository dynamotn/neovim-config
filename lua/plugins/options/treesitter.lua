local present, treesitter = pcall(require, 'nvim-treesitter.configs')

if not present then
    return
end

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

treesitter.setup({
    highlight = {
        enable = true,
        use_languagetree = true,
    },
    incremental_selection = {
        enable = true,
    },
    indent = {
        enable = true,
    },
    autotag = {
        enable = true,
    },
    ensure_installed = {
        'lua',
    },
})

require('nvim-treesitter.install').prefer_git = true
