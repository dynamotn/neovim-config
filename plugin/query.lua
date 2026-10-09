-- `:DyQuery [{expr}]`: a jq or yq expression tried against this JSON or
-- YAML buffer as it is typed. The module only loads when asked.
vim.api.nvim_create_user_command(
  'DyQuery',
  function(args) require('tools.query').command(args) end,
  { nargs = '*', desc = 'Try a jq or yq expression against this buffer' }
)
