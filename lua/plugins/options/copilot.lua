local copilot = require('copilot')

copilot.setup({
  panel = { enabled = false },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    debounce = 75,
    keymap = {
      accept = '<M-CR>',
      accept_word = false,
      accept_line = '<M-Space>',
      next = '<C-n>',
      prev = '<C-p>',
      dismiss = '<C-c>',
    },
  },
  server_opts_overrides = {
    settings = {
      advanced = {
        inlineSuggestCount = 5,
      },
    },
  },
})

local auth = require('copilot.auth')
if not auth.get_cred().user then
  auth.signin()
end
