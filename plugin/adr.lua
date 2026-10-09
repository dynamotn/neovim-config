-- `:DyAdr`: the architecture decision records of the project. The module only
-- loads when asked.
vim.api.nvim_create_user_command(
  'DyAdr',
  function(args) require('tools.adr').command(args) end,
  {
    nargs = '*',
    complete = function(lead, line)
      if line:match('^%S+%s+%S+%s') then
        if line:match('^%S+%s+status%s') then
          return vim.tbl_map(string.lower, require('tools.adr').STATUSES)
        end
        return {}
      end
      return vim.tbl_filter(
        function(word) return word:find(lead, 1, true) == 1 end,
        require('tools.adr').SUBCOMMANDS
      )
    end,
    desc = 'Write, list and supersede architecture decision records',
  }
)
