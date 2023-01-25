return function(register_config, filetypes)
  return {
    { 'kristijanhusak/vim-dadbod-completion', name = 'cmp_dadbod', config = register_config }, -- SQL completion source
    { 'nanotee/sqls.nvim', name = 'sqls', config = register_config }, -- SQL LSP
  }
end
