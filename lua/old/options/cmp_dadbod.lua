vim.g.completion_chain_complete_list = {
  sql = {
    { complete_items = { 'vim-dadbod-completion' } },
  },
}
vim.g.completion_matching_strategy_list = { 'exact', 'substring' }
vim.g.completion_matching_ignore_case = 1
