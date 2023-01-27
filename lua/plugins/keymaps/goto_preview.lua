local goto_preview = require('goto-preview')

return {
  {
    'gpd',
    function()
      goto_preview.goto_preview_definition()
    end,
    desc = 'Preview definition',
  },
  {
    'gpt',
    function()
      goto_preview.goto_preview_type_definition()
    end,
    desc = 'Preview type definition',
  },
  {
    'gpi',
    function()
      goto_preview.goto_preview_implementation()
    end,
    desc = 'Preview implementation',
  },
  {
    'gpr',
    function()
      goto_preview.goto_preview_references()
    end,
    desc = 'Preview references',
  },
}
