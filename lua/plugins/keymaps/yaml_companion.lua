local yaml_companion = require('yaml-companion')

return {
  {
    '<Space>ly',
    function()
      yaml_companion.open_ui_select()
    end,
    desc = 'Choose YAML schema',
  },
}
