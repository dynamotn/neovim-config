-- `:DyInspect`: what the certificate, key or JWT under the cursor says, and
-- `:DyInspect expiry` for every certificate of the buffer. The module only
-- loads when asked.
vim.api.nvim_create_user_command(
  'DyInspect',
  function(args) require('tools.inspect').command(args) end,
  {
    nargs = '?',
    complete = function() return { 'expiry' } end,
    desc = 'Decode the certificate, key or JWT under the cursor',
  }
)
