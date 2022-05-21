local present, treesitter = pcall(require, 'nvim-treesitter.configs')

if not present then
  return
end

local parser_config = require('nvim-treesitter.parsers').filetype_to_parsername

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

local present, languages = pcall(require, 'languages')
local parsers = DEBUG and { 'query' } or {}

if present then
  parsers, _ = languages.setup_treesitter(parser_config)
end

table.insert(parsers, 'org')

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
