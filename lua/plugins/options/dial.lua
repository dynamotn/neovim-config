local present, dial = pcall(require, 'dial')

if not present then
  return
end

local augend = dial.augend
dial.config.augends:register_group({
  default = {
    augend.integer.alias.decimal_int, -- decimal number (0, 1, 2, 3, ...)
    augend.constant.alias.alpha, -- lowercase alphabet letter
    augend.constant.alias.Alpha, -- uppercase alphabet letter
    augend.integer.alias.hex, -- hex number  (0x01, 0x1a1f, ...)
    augend.date.alias['%Y/%m/%d'], -- date (2022/02/19, ...)
    augend.date.alias['%d/%m/%Y'], -- date (19/02/2022, ...)
    augend.constant.alias.bool, -- boolean value (true <-> false)
    augend.constant.alias.semver, -- semver
    augend.hexcolor.new({ case = 'upper' }), -- uppercase hex color
    augend.hexcolor.new({ case = 'lower' }), -- lowercase hex color
  },
})
