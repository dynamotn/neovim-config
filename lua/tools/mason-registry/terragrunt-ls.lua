return {
  name = 'terragrunt-ls',
  description = 'Terragrunt Language Server',
  homepage = 'https://github.com/gruntwork-io/terragrunt-ls',
  licenses = {
    'MPL-2.0',
  },
  languages = {
    'Terragrunt',
  },
  categories = {
    'LSP',
  },
  source = {
    id = 'pkg:golang/github.com/dynamotn/terragrunt-ls@v0.1.0',
  },
  bin = {
    ['terragrunt-ls'] = 'golang:terragrunt-ls',
  },
  neovim = {
    lspconfig = 'terragruntls',
  },
}
