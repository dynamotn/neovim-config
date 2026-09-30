return {
  name = 'betterleaks',
  description = 'Find secrets in code, the successor of gitleaks',
  homepage = 'https://github.com/betterleaks/betterleaks',
  licenses = {
    'MIT',
  },
  languages = {},
  categories = {
    'Linter',
  },
  source = {
    id = 'pkg:github/betterleaks/betterleaks@v1.9.0',
    asset = {
      {
        target = 'darwin_arm64',
        file = 'betterleaks_{{ version | strip_prefix "v" }}_darwin_arm64.tar.gz',
        bin = 'betterleaks',
      },
      {
        target = 'darwin_x64',
        file = 'betterleaks_{{ version | strip_prefix "v" }}_darwin_x64.tar.gz',
        bin = 'betterleaks',
      },
      {
        target = 'linux_arm64',
        file = 'betterleaks_{{ version | strip_prefix "v" }}_linux_arm64.tar.gz',
        bin = 'betterleaks',
      },
      {
        target = 'linux_x64',
        file = 'betterleaks_{{ version | strip_prefix "v" }}_linux_x64.tar.gz',
        bin = 'betterleaks',
      },
    },
  },
  bin = {
    betterleaks = '{{source.asset.bin}}',
  },
}
