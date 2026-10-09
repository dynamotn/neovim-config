-- `:DyTfState`: what the Terraform state holds for the block under the
-- cursor, what it holds that the code no longer declares, and an `import`
-- block for an object it does not hold yet. The module only loads when
-- asked, or when a Terraform buffer opens.
vim.api.nvim_create_user_command(
  'DyTfState',
  function(args) require('tools.tfstate').command(args) end,
  {
    nargs = '?',
    complete = function()
      local names = vim.tbl_keys(require('tools.tfstate').SUBCOMMANDS)
      table.sort(names)
      return names
    end,
    desc = 'The Terraform state of the block under the cursor',
  }
)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('dy_tfstate', { clear = true }),
  pattern = { 'terraform', 'tf' },
  callback = function(args) require('tools.tfstate').attach(args.buf) end,
})
