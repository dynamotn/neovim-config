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
  source = {
    id = 'pkg:github/gruntwork-io/terragrunt@v1.1.6',
    asset = {
      {
        target = 'darwin_arm64',
        file = 'terragrunt_darwin_arm64',
        bin = 'terragrunt_darwin_arm64',
      },
      {
        target = 'darwin_x64',
        file = 'terragrunt_darwin_amd64',
        bin = 'terragrunt_darwin_amd64',
      },
      {
        target = 'linux_arm64',
        file = 'terragrunt_linux_arm64',
        bin = 'terragrunt_linux_arm64',
      },
      {
        target = 'linux_x64',
        file = 'terragrunt_linux_amd64',
        bin = 'terragrunt_linux_amd64',
      },
      {
        target = 'win_x64',
        file = 'terragrunt_windows_amd64.exe',
        bin = 'terragrunt_windows_amd64.exe',
      },
    },
  },
  bin = {
    terragrunt = '{{source.asset.bin}}',
  },
}
