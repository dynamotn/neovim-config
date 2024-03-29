local dial = require('dial.config')

local augend = require('dial.augend')
local configs = require('languages').setup_dial(augend)

local default_group = {
  augend.integer.alias.decimal_int, -- decimal number (0, 1, 2, 3, ...)
  augend.constant.alias.alpha, -- lowercase alphabet letter
  augend.constant.alias.Alpha, -- uppercase alphabet letter
  augend.integer.alias.hex, -- hex number  (0x01, 0x1a1f, ...)
  augend.date.alias['%Y/%m/%d'], -- date (2022/02/19, ...)
  augend.date.alias['%d/%m/%Y'], -- date (19/02/2022, ...)
  augend.constant.alias.bool, -- boolean value (true <-> false)
  augend.semver.alias.semver, -- semver
  augend.hexcolor.new({ case = 'upper' }),
  augend.hexcolor.new({ case = 'lower' }),
  augend.constant.new({
    elements = { 'and', 'or' },
    word = true,
    cyclic = true,
  }),
  augend.constant.new({
    elements = { '&&', '||' },
    word = false,
    cyclic = true,
  }),
  augend.constant.new({
    elements = { 'public', 'protected', 'private' },
    word = false,
    cyclic = true,
  }),
}

local groups = {
  default = default_group,
}

for language, config in pairs(configs) do
  groups[language] = vim.tbl_extend('force', default_group, config)
end

dial.augends:register_group(groups)
