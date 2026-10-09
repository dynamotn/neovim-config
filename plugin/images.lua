-- `:DyImageScan`, `:DyImagePin`: the container images of a Dockerfile, a
-- manifest or a compose file, scanned for known vulnerabilities and pinned
-- to their digests. The module only loads when asked.
vim.api.nvim_create_user_command(
  'DyImageScan',
  function() require('tools.images').scan(0) end,
  { desc = 'Scan the images this file names for known vulnerabilities' }
)
vim.api.nvim_create_user_command(
  'DyImagePin',
  function() require('tools.images').pin(0) end,
  { desc = 'Pin the images this file names to their digests' }
)
