local present, barbecue = pcall(require, 'barbecue')

if not present then
  return
end

barbecue.setup({
  symbols = {
    separator = '>',
  },
  kinds = {
    File = ' ',
    Module = ' ',
    Namespace = ' ',
    Package = ' ',
    Class = ' ',
    Method = ' ',
    Property = ' ',
    Field = ' ',
    Constructor = ' ',
    Enum = '練',
    Interface = ' ',
    Function = ' ',
    Variable = '',
    Constant = ' ',
    String = ' ',
    Number = ' ',
    Boolean = '◩ ',
    Array = ' ',
    Object = ' ',
    Key = ' ',
    Null = 'ﳠ ',
    EnumMember = ' ',
    Struct = ' ',
    Event = ' ',
    Operator = ' ',
    TypeParameter = ' ',
  },
})
