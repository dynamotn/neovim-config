return {
  name = 'scalafmt',
  description = 'A code formatter for Scala',
  homepage = 'https://github.com/scalameta/scalafmt',
  licenses = {
    'Apache-2.0',
  },
  languages = {
    'Scala',
  },
  categories = {
    'Formatter',
  },
  source = {
    id = 'pkg:github/scalameta/scalafmt@v3.11.5',
    asset = {
      {
        target = 'darwin_arm64',
        file = 'scalafmt-aarch64-apple-darwin.zip',
        bin = 'scalafmt',
      },
      {
        target = 'darwin_x64',
        file = 'scalafmt-x86_64-apple-darwin.zip',
        bin = 'scalafmt',
      },
      {
        target = 'linux_arm64',
        file = 'scalafmt-aarch64-pc-linux.zip',
        bin = 'scalafmt',
      },
      {
        target = 'linux_x64',
        file = 'scalafmt-linux-glibc',
        bin = 'scalafmt-linux-glibc',
      },
    },
  },
  bin = {
    scalafmt = '{{source.asset.bin}}',
  },
}
