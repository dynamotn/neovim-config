-- `:DyAi`: prompts sent with the code they are about, and a picker over
-- every AI action. The module only loads when asked.
vim.api.nvim_create_user_command(
  'DyAi',
  function(args) require('tools.ai').command(args) end,
  {
    nargs = '?',
    range = true,
    complete = function(lead) return require('tools.ai').complete(lead) end,
    desc = 'Send a prompt about the code to the AI, or pick an AI action',
  }
)
