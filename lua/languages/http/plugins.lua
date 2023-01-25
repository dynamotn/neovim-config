return function(register_config, filetypes)
  return {
    { 'rest-nvim/rest.nvim', name = 'rest', config = register_config }, -- HTTP client
  }
end
