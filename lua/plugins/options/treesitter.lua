local treesitter = require('nvim-treesitter.configs')
local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

local languages = require('languages')
languages.setup_treesitter(parser_config)

local parsers = { 'diff', 'regex', 'comment', 'query', 'vim' }

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

-- Check has parser installed
local function is_installed(parser)
  if
    next(vim.api.nvim_get_runtime_file('parser/' .. parser .. '.so', true))
    == nil
  then
    return false
  else
    return true
  end
end

-- Automatically install parsers for filetypes that are not installed
local function auto_install(bufnr)
  local bufnr = bufnr or vim.api.nvim_get_current_buf()
  local parsers =
    languages.get_parsers_by_filetype(vim.api.nvim_buf_get_option(bufnr, 'ft'))
  for _, parser in ipairs(parsers) do
    if not is_installed(parser) then
      vim.api.nvim_command('TSInstall ' .. parser)
    end
  end
end

for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(bufnr) then
    auto_install(bufnr)
  end
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { '*' },
  callback = function()
    auto_install()
  end,
})
