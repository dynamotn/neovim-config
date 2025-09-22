local h = require('null-ls.helpers')
local methods = require('null-ls.methods')

return h.make_builtin({
  name = 'condense_blank_lines',
  meta = {
    description = 'Condense multiple blank lines to only one line',
  },
  method = methods.internal.FORMATTING,
  filetypes = {},
  generator_opts = {
    command = 'sed',
    args = { ':a;N;$!ba;s/\\n\\n\\+/\\n\\n/g' },
    to_stdin = true,
  },
  factory = h.formatter_factory,
})
