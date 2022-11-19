return function(require_config, filetypes)
  return {
    { 'kristijanhusak/vim-dadbod-completion', config = require_config('cmp_dadbod', filetypes) }, -- SQL completion source
    { 'nanotee/sqls.nvim', config = require_config('sqls', filetypes) }, -- SQL LSP
  }
end
