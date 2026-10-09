-- `:DyKube`: diff, validate, apply and render the manifest, kustomization or
-- Helm chart being edited. The module only loads when asked, or when a YAML
-- buffer opens.
vim.api.nvim_create_user_command(
  'DyKube',
  function(args) require('tools.kube').command(args) end,
  {
    nargs = '?',
    complete = function(lead)
      local names = vim.tbl_keys(require('tools.kube').SUBCOMMANDS)
      table.sort(names)
      return vim.tbl_filter(
        function(name) return name:find(lead, 1, true) == 1 end,
        names
      )
    end,
    desc = 'Diff, validate, apply or render this manifest for a cluster',
  }
)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('dy_kube', { clear = true }),
  pattern = { 'yaml', 'yaml.*', 'helm' },
  callback = function(args) require('tools.kube').attach(args.buf) end,
})
