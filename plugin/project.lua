-- `:DyProject`: the state of the project on one page. The module only loads
-- when asked.
vim.api.nvim_create_user_command(
  'DyProject',
  function() require('tools.project').open() end,
  { desc = 'The branch, diagnostics, tasks, reviews, pipeline and issues' }
)
