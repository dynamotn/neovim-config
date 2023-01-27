local plugin = require('textcase.plugin.plugin')
local api = require('textcase.plugin.api')
local prefix = '<Space>xc'

plugin.register_keybindings(prefix, api.to_upper_case, {
  prefix = prefix,
  quick_replace = 'u',
  operator = 'ou',
  lsp_rename = 'U',
})

plugin.register_keybindings(prefix, api.to_lower_case, {
  prefix = prefix,
  quick_replace = 'l',
  operator = 'ol',
  lsp_rename = 'L',
})

plugin.register_keybindings(prefix, api.to_snake_case, {
  prefix = prefix,
  quick_replace = 's',
  operator = 'os',
  lsp_rename = 'S',
})

plugin.register_keybindings(prefix, api.to_dash_case, {
  prefix = prefix,
  quick_replace = 'd',
  operator = 'od',
  lsp_rename = 'D',
})

plugin.register_keybindings(prefix, api.to_constant_case, {
  prefix = prefix,
  quick_replace = 'n',
  operator = 'on',
  lsp_rename = 'N',
})

plugin.register_keybindings(prefix, api.to_dot_case, {
  prefix = prefix,
  quick_replace = 'o',
  operator = 'oo',
  lsp_rename = 'O',
})

plugin.register_keybindings(prefix, api.to_phrase_case, {
  prefix = prefix,
  quick_replace = 'f',
  operator = 'of',
  lsp_rename = 'F',
})

plugin.register_keybindings(prefix, api.to_camel_case, {
  prefix = prefix,
  quick_replace = 'c',
  operator = 'oc',
  lsp_rename = 'C',
})

plugin.register_keybindings(prefix, api.to_pascal_case, {
  prefix = prefix,
  quick_replace = 'p',
  operator = 'op',
  lsp_rename = 'P',
})

plugin.register_keybindings(prefix, api.to_title_case, {
  prefix = prefix,
  quick_replace = 't',
  operator = 'ot',
  lsp_rename = 'T',
})

plugin.register_keybindings(prefix, api.to_path_case, {
  prefix = prefix,
  quick_replace = 'h',
  operator = 'oh',
  lsp_rename = 'H',
})

return {
  { prefix, nil },
}
