return {
  name = 'just',
  description = 'A command runner, with its own formatter',
  homepage = 'https://github.com/casey/just',
  licenses = {
    'CC0-1.0',
  },
  languages = {
    'Just',
  },
  categories = {
    'Formatter',
  },
  source = {
    id = 'pkg:github/casey/just@1.58.0',
    asset = {
      {
        target = 'darwin_arm64',
        file = 'just-{{version}}-aarch64-apple-darwin.tar.gz',
        bin = 'just',
      },
      {
        target = 'darwin_x64',
        file = 'just-{{version}}-x86_64-apple-darwin.tar.gz',
        bin = 'just',
      },
      {
        target = 'linux_arm64',
        file = 'just-{{version}}-aarch64-unknown-linux-musl.tar.gz',
        bin = 'just',
      },
      {
        target = 'linux_x64',
        file = 'just-{{version}}-x86_64-unknown-linux-musl.tar.gz',
        bin = 'just',
      },
    },
  },
  bin = {
    just = '{{source.asset.bin}}',
  },
}
