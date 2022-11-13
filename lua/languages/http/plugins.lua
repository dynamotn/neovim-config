return function(register_config, filetypes)
  return {
    { 'rest-nvim/rest.nvim', config = register_config('rest', filetypes) }, -- HTTP client
  }
end
