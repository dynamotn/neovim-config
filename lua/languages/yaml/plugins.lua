return function(require_config, filetypes)
  return {
    { 'someone-stole-my-name/yaml-companion.nvim', config = require_config('yaml_companion', nil, filetypes) }, -- Autodetect YAML schema
  }
end
