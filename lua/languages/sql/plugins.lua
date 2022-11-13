return function(require_config, filetypes)
  return {
    { 'kristijanhusak/vim-dadbod-completion', config = require_config('cmp_dadbod', filetypes) }, -- SQL completion source
  }
end
