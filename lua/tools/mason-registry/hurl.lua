return {
  name = 'hurl',
  description = 'Run and test HTTP requests in plain text, for the hurlfmt it ships',
  homepage = 'https://github.com/Orange-OpenSource/hurl',
  licenses = {
    'Apache-2.0',
  },
  languages = {
    'Hurl',
  },
  categories = {
    'Formatter',
  },
  source = {
    id = 'pkg:github/Orange-OpenSource/hurl@8.0.1',
    asset = {
      {
        target = 'darwin_arm64',
        file = 'hurl-{{version}}-aarch64-apple-darwin.tar.gz',
        bin = 'hurl-{{version}}-aarch64-apple-darwin/bin/hurlfmt',
      },
      {
        target = 'darwin_x64',
        file = 'hurl-{{version}}-x86_64-apple-darwin.tar.gz',
        bin = 'hurl-{{version}}-x86_64-apple-darwin/bin/hurlfmt',
      },
      {
        target = 'linux_arm64',
        file = 'hurl-{{version}}-aarch64-unknown-linux-gnu.tar.gz',
        bin = 'hurl-{{version}}-aarch64-unknown-linux-gnu/bin/hurlfmt',
      },
      {
        target = 'linux_x64',
        file = 'hurl-{{version}}-x86_64-unknown-linux-gnu.tar.gz',
        bin = 'hurl-{{version}}-x86_64-unknown-linux-gnu/bin/hurlfmt',
      },
    },
  },
  bin = {
    hurlfmt = '{{source.asset.bin}}',
  },
}
