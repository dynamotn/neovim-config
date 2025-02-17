local lspsaga = require('lspsaga')
local icons = require('core.defaults').icons.kinds

lspsaga.setup({
  symbol_in_winbar = {
    enable = false,
  },
  ui = {
    kind = {
      File = { icons.File, 'Tag' },
      Module = { icons.Module, 'Exception' },
      Namespace = { icons.Namespace, 'Include' },
      Package = { icons.Package, 'Label' },
      Class = { icons.Class, 'Include' },
      Method = { icons.Method, 'Function' },
      Property = { icons.Property, '@property' },
      Field = { icons.Field, '@field' },
      Constructor = { icons.Constructor, '@constructor' },
      Enum = { icons.Enum, '@number' },
      Interface = { icons.Interface, 'Type' },
      Function = { icons.Function, 'Function' },
      Variable = { icons.Variable, '@variable' },
      Constant = { icons.Constant, 'Constant' },
      String = { icons.String, 'String' },
      Number = { icons.Number, 'Number' },
      Boolean = { icons.Boolean, 'Boolean' },
      Array = { icons.Array, 'Type' },
      Object = { icons.Object, 'Type' },
      Key = { icons.Keyword, 'Constant' },
      Null = { icons.Null, 'Constant' },
      EnumMember = { icons.EnumMember, 'Number' },
      Struct = { icons.Struct, 'Type' },
      Event = { icons.Event, 'Constant' },
      Operator = { icons.Operator, 'Operator' },
      TypeParameter = { icons.TypeParameter, 'Type' },
    },
  },
})
