local h = require('null-ls.helpers')
local methods = require('null-ls.methods')

return h.make_builtin({
  name = 'ltcc',
  meta = {
    description = 'My custom sources to use languagetool-code-comments',
    url = 'https://github.com/dynamotn/languagetool-code-comments',
  },
  method = methods.internal.DIAGNOSTICS,
  filetypes = {},
  generator_opts = {
    command = 'ltcc',
    args = { 'check', '-l', 'en-US', '-f', '$FILENAME' },
    format = 'json',
    to_stdin = true,
    timeout = 60000,
    check_exit_code = function(c) return c <= 1 end,
    on_output = require('tools.diagnostics.ltcc.executor').handle_output,
    use_cache = false,
  },
  factory = h.generator_factory,
})
