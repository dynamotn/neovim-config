-- `:DyRunbook`: run the code blocks of a Markdown runbook where they are
-- written, their output under them. The module only loads when asked.
vim.api.nvim_create_user_command(
  'DyRunbook',
  function(args) require('tools.runbook').command(args) end,
  {
    nargs = '?',
    complete = function(lead)
      return vim.tbl_filter(
        function(word) return word:find(lead, 1, true) == 1 end,
        require('tools.runbook').SUBCOMMANDS
      )
    end,
    desc = 'Run the code block under the cursor, or all of them, in place',
  }
)
