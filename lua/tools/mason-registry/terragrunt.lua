return {
  name = 'terragrunt',
  description = 'Orchestration tool for OpenTofu and Terraform, with its own HCL formatter and validator',
  homepage = 'https://github.com/gruntwork-io/terragrunt',
  licenses = {
    'MIT',
  },
  languages = {
    'Terragrunt',
  },
  categories = {
    'Formatter',
    'Linter',
  },
  -- dytoy downloads the release, as on the rest of the machine; see
  -- `tools.mason-dytoy`
  source = {
    id = 'dytoy:terragrunt',
  },
  bin = {
    terragrunt = 'terragrunt',
  },
}
