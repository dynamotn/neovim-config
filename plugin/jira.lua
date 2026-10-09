-- `:DyJira`: the issues assigned, and the chores of one -- a branch, a move, a
-- worklog -- through jira-cli. The module only loads when asked.
vim.api.nvim_create_user_command(
  'DyJira',
  function(args) require('tools.jira').command(args) end,
  {
    nargs = '*',
    complete = function(lead, line)
      local words = vim.split(line, '%s+', { trimempty = true })
      local done = #words - (line:sub(-1) == ' ' and 0 or 1)
      if done > 1 then return {} end
      return vim.tbl_filter(
        function(word) return word:find(lead, 1, true) == 1 end,
        require('tools.jira').SUBCOMMANDS
      )
    end,
    desc = 'Jira issues through jira-cli: pick, branch, move, log work',
  }
)
