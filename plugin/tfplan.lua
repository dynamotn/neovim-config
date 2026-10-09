-- `:TfPlan`: a Terraform or OpenTofu plan, shown on the blocks it changes.
-- The module only loads when asked, or when a Terraform buffer opens.
vim.api.nvim_create_user_command(
  'TfPlan',
  function(args) require('tools.tfplan').command(args) end,
  {
    nargs = '?',
    complete = function() return require('tools.tfplan').SUBCOMMANDS end,
    desc = 'Plan the module of this buffer, and show it on its blocks',
  }
)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('dy_tfplan', { clear = true }),
  pattern = { 'terraform', 'tf' },
  callback = function(args) require('tools.tfplan').attach(args.buf) end,
})
