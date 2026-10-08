return {
  name = 'opentofu',
  description = 'Open source infrastructure as code tool, a fork of Terraform',
  homepage = 'https://github.com/opentofu/opentofu',
  licenses = {
    'MPL-2.0',
  },
  languages = {
    'Terraform',
  },
  categories = {
    'Formatter',
    'Linter',
  },
  source = {
    id = 'pkg:github/opentofu/opentofu@v1.13.0',
    asset = {
      {
        target = 'darwin_arm64',
        file = 'tofu_{{ version | strip_prefix "v" }}_darwin_arm64.tar.gz',
        bin = 'tofu',
      },
      {
        target = 'darwin_x64',
        file = 'tofu_{{ version | strip_prefix "v" }}_darwin_amd64.tar.gz',
        bin = 'tofu',
      },
      {
        target = 'linux_arm64',
        file = 'tofu_{{ version | strip_prefix "v" }}_linux_arm64.tar.gz',
        bin = 'tofu',
      },
      {
        target = 'linux_x64',
        file = 'tofu_{{ version | strip_prefix "v" }}_linux_amd64.tar.gz',
        bin = 'tofu',
      },
    },
  },
  bin = {
    tofu = '{{source.asset.bin}}',
  },
}
