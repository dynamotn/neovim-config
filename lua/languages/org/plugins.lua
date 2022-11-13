return function(register_config, filetypes)
  return {
    { 'nvim-orgmode/orgmode', config = register_config('orgmode', filetypes) }, -- Org managed plugin
  }
end
