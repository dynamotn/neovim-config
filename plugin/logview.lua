-- `:DyLog`: a log file, the journal or the logs of a pod, read as records.
-- The module only loads when asked.
vim.api.nvim_create_user_command(
  'DyLog',
  function(args) require('tools.logview').command(args) end,
  {
    nargs = '+',
    complete = function(lead, line)
      -- Only the first argument is a subcommand or a file
      if line:match('^%S+%s+%S+%s') then return {} end
      return vim.list_extend(
        vim.tbl_filter(
          function(word) return word:find(lead, 1, true) == 1 end,
          { 'journal', 'kube' }
        ),
        vim.fn.getcompletion(lead, 'file')
      )
    end,
    desc = 'Read a log file, the journal or the logs of a pod as records',
  }
)
