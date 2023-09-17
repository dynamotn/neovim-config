return {
  {
    '<Space>ly',
    function()
      require('yaml-companion').open_ui_select()
    end,
    desc = 'Choose YAML schema',
  },
}
