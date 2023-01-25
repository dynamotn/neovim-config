return function(register_config, filetypes)
  return {
    { 'someone-stole-my-name/yaml-companion.nvim', name = 'yaml_companion', config = register_config }, -- Autodetect YAML schema
  }
end
