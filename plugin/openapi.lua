-- `:DyOpenApiRequest`: the OpenAPI operation under the cursor as a kulala or
-- Hurl request. The module only loads when asked, or when such a file opens.
vim.api.nvim_create_user_command(
  'DyOpenApiRequest',
  function(args) require('tools.openapi').command(args) end,
  {
    nargs = '?',
    complete = function() return { 'http', 'hurl' } end,
    desc = 'Open the operation under the cursor as a kulala or Hurl request',
  }
)

-- `:DyOpenApiDiff [{rev}]`: what this document, as it is now, breaks of
-- itself at {rev}
vim.api.nvim_create_user_command(
  'DyOpenApiDiff',
  function(args) require('tools.openapi').diff(0, args.fargs[1]) end,
  {
    nargs = '?',
    desc = 'The breaking changes of this OpenAPI document since a revision',
  }
)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('dy_openapi', { clear = true }),
  pattern = { 'yaml.openapi', 'json.openapi' },
  callback = function(args) require('tools.openapi').attach(args.buf) end,
})
