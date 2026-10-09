-- `:ActionsPin`: every action of this GitHub workflow pinned to the commit
-- its ref points at. The module only loads when asked, or when a workflow
-- opens.
vim.api.nvim_create_user_command(
  'ActionsPin',
  function() require('tools.actions').pin(0) end,
  { desc = 'Pin the actions of this workflow to full commits' }
)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('dy_actions', { clear = true }),
  pattern = 'yaml.gh-action',
  callback = function(args) require('tools.actions').attach(args.buf) end,
})
