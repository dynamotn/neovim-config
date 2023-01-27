return {
  {
    'kristijanhusak/vim-dadbod-completion',
    name = 'cmp_dadbod',
    event = 'InsertEnter',
  }, -- SQL completion source
  { 'nanotee/sqls.nvim' }, -- SQL LSP
}
