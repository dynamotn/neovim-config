local treesitter = require('nvim-treesitter.configs')
local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

local languages = require('languages')
local parsers =
  { 'diff', 'regex', 'comment', 'query', 'vim', 'markdown_inline' }
parsers =
  vim.tbl_extend('force', languages.setup_treesitter(parser_config), parsers)

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
  ensure_installed = parsers,
})

require('nvim-treesitter.install').prefer_git = true
