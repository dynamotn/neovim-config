local copilot = require('copilot')

copilot.setup({
  panel = { enabled = false },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    debounce = 75,
    keymap = {
      accept = '<C-CR>',
      accept_word = false,
      accept_line = '<C-Space>',
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
