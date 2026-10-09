-- `:DyArchitecture`: the D2 diagram of what the directory of this buffer
-- declares -- Terraform, Kubernetes manifests or a compose file. The module
-- only loads when asked.
vim.api.nvim_create_user_command(
  'DyArchitecture',
  function() require('tools.architecture').open() end,
  { desc = 'Draw what this directory declares as a D2 diagram' }
)
