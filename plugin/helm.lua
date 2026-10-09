-- `:DyHelmValue`, `:DyHelmUsages`, `:DyHelmUnused`: the values of a Helm chart
-- and the templates using them, one key away. The module only loads when
-- asked, or when a template or the values of a chart open.
vim.api.nvim_create_user_command(
  'DyHelmValue',
  function() require('tools.helm').value() end,
  { desc = 'Go to the value under the cursor in values.yaml' }
)
vim.api.nvim_create_user_command(
  'DyHelmUsages',
  function() require('tools.helm').show_usages() end,
  { desc = 'List the template lines using the key under the cursor' }
)
vim.api.nvim_create_user_command(
  'DyHelmUnused',
  function() require('tools.helm').unused(0) end,
  { desc = 'Mark the values no template uses' }
)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('dy_helm', { clear = true }),
  pattern = { 'helm', 'yaml.helm-values' },
  callback = function(args) require('tools.helm').attach(args.buf) end,
})
