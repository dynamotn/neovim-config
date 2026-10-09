return {
  name = 'conftest',
  description = 'Test configuration files against Open Policy Agent Rego policies',
  homepage = 'https://www.conftest.dev',
  licenses = {
    'Apache-2.0',
  },
  languages = {
    'YAML',
    'Rego',
  },
  categories = {
    'Linter',
  },
  source = {
    id = 'pkg:github/open-policy-agent/conftest@v0.70.1',
    asset = {
      {
        target = 'darwin_arm64',
        file = 'conftest_{{ version | strip_prefix "v" }}_Darwin_arm64.tar.gz',
        bin = 'conftest',
      },
      {
        target = 'darwin_x64',
        file = 'conftest_{{ version | strip_prefix "v" }}_Darwin_x86_64.tar.gz',
        bin = 'conftest',
      },
      {
        target = 'linux_arm64',
        file = 'conftest_{{ version | strip_prefix "v" }}_Linux_arm64.tar.gz',
        bin = 'conftest',
      },
      {
        target = 'linux_x64',
        file = 'conftest_{{ version | strip_prefix "v" }}_Linux_x86_64.tar.gz',
        bin = 'conftest',
      },
    },
  },
  bin = {
    conftest = '{{source.asset.bin}}',
  },
}
