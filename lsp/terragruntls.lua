return {
  cmd = { 'terragrunt-ls' },
  -- Not `hcl`: Packer and Nomad files keep it, and are no Terragrunt
  filetypes = { 'terragrunt' },
  root_markers = { '.git', 'terragrunt.hcl' },
}
