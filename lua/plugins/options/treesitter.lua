local present, treesitter = pcall(require, 'nvim-treesitter.configs')

if not present then
    return
end

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

local present, languages = pcall(require, 'languages')
local parsers = {}

if present then
    parsers = languages.setup_treesitter()
end

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
    ensure_installed = parsers,
})

require('nvim-treesitter.install').prefer_git = true
