local present, treesitter = pcall(require, 'nvim-treesitter.configs')

if not present then
  return
end

local ft_to_parser = require('nvim-treesitter.parsers').filetype_to_parsername
local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

local present, languages = pcall(require, 'languages')
local parsers = { 'diff', 'regex', 'comment', 'query', 'vim', 'markdown_inline' }

if present then
  parsers = languages.setup_treesitter(ft_to_parser, parser_config)
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
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['af'] = { query = '@function.outer', desc = 'outer part of a function' },
        ['if'] = { query = '@function.inner', desc = 'inner part of a function' },
        ['ac'] = { query = '@class.outer', desc = 'outer part of a class' },
        ['ic'] = { query = '@class.inner', desc = 'inner part of a class' },
      },
      selection_modes = {
        ['@parameter.outer'] = 'v',
        ['@function.outer'] = 'V',
        ['@class.outer'] = '<c-v>',
      },
      include_surrounding_whitespace = true,
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>sp'] = { query = '@parameter.inner', desc = 'Swap to next parameter' },
      },
      swap_previous = {
        ['<leader>sP'] = { query = '@parameter.inner', desc = 'Swap to previous parameter' },
      },
    },
  },
})

require('nvim-treesitter.install').prefer_git = true
