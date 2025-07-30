return {
  name = 'd2',
  description = 'A modern diagram scripting language',
  homepage = 'https://d2lang.com',
  licenses = {
    'MPL2',
  },
  languages = {},
  categories = {
    'Formatter',
  },
  source = {
    id = 'pkg:github/terrastruct/d2@v0.7.0',
    asset = {
      {
        target = 'darwin_x64',
        file = 'd2-{{ version }}-macos-amd64.tar.gz',
        bin = 'd2-{{ version }}/bin/d2',
      },
      {
        target = 'darwin_arm64',
        file = 'd2-{{ version }}-macos-arm64.tar.gz',
        bin = 'd2-{{ version }}/bin/d2',
      },
      {
        target = 'linux_x64',
        file = 'd2-{{ version }}-linux-amd64.tar.gz',
        bin = 'd2-{{ version }}/bin/d2',
      },
      {
        target = 'linux_arm64',
        file = 'd2-{{ version }}-linux-arm64.tar.gz',
        bin = 'd2-{{ version }}/bin/d2',
      },
    },
    bin = {
      d2 = '{{source.asset.bin}}',
    },
  },
}
