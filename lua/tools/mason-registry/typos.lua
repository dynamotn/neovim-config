return {
  name = 'typos',
  description = 'Source code spell checker',
  homepage = 'https://github.com/crate-ci/typos',
  licenses = {
    'MIT',
    'Apache-2.0',
  },
  languages = {},
  categories = {
    'Linter',
  },
  source = {
    id = 'pkg:github/crate-ci/typos@v1.80.0',
    asset = {
      {
        target = 'darwin_x64',
        file = 'typos-{{ version }}-x86_64-apple-darwin.tar.gz',
        bin = 'typos',
      },
      {
        target = 'darwin_arm64',
        file = 'typos-{{ version }}-aarch64-apple-darwin.tar.gz',
        bin = 'typos',
      },
      {
        target = 'linux_x64',
        file = 'typos-{{ version }}-x86_64-unknown-linux-musl.tar.gz',
        bin = 'typos',
      },
      {
        target = 'win_x64',
        file = 'typos-{{ version }}-x86_64-pc-windows-msvc.zip',
        bin = 'typos.exe',
      },
    },
  },
  bin = {
    typos = '{{source.asset.bin}}',
  },
}
