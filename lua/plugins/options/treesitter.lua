local treesitter = require('nvim-treesitter.configs')
local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

local languages = require('languages')
languages.setup_treesitter(parser_config)

local parsers = { 'diff', 'regex', 'comment', 'query', 'vim' }

for _, language in ipairs(DEFAULT_ENABLED_LANGUAGES) do
  parsers = vim.tbl_extend('force', parsers, languages.get_parsers_by_language(language))
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
  ensure_installed = parsers,
})

require('nvim-treesitter.install').prefer_git = true
