local h = require('null-ls.helpers')
local methods = require('null-ls.methods')

return h.make_builtin({
  name = 'jira',
  meta = {
    description = 'My custom sources to complete JIRA issue ',
    url = 'https://github.com/ankitpokhrel/jira-cli',
  },
  method = methods.internal.COMPLETION,
  filetypes = { 'gitcommit' },
  generator = {
    fn = require('tools.completion.jira.queries').setup,
    async = true,
  },
})
