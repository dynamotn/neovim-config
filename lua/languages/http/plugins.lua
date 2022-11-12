return function(register_config, filetypes)
  return {
    { -- HTTP client
      'rest-nvim/rest.nvim',
      config = register_config('rest', nil, filetypes),
    },
  }
end
