return {
  name = 'bicep',
  description = 'Language to deploy Azure resources, with its formatter',
  homepage = 'https://github.com/Azure/bicep',
  licenses = {
    'MIT',
  },
  languages = {
    'Bicep',
  },
  categories = {
    'Formatter',
  },
  source = {
    id = 'pkg:github/Azure/bicep@v0.47.16',
    asset = {
      {
        target = 'darwin_arm64',
        file = 'bicep-osx-arm64',
        bin = 'bicep-osx-arm64',
      },
      {
        target = 'darwin_x64',
        file = 'bicep-osx-x64',
        bin = 'bicep-osx-x64',
      },
      {
        target = 'linux_arm64',
        file = 'bicep-linux-arm64',
        bin = 'bicep-linux-arm64',
      },
      {
        target = 'linux_x64',
        file = 'bicep-linux-x64',
        bin = 'bicep-linux-x64',
      },
      {
        target = 'win_x64',
        file = 'bicep-win-x64.exe',
        bin = 'bicep-win-x64.exe',
      },
    },
  },
  bin = {
    bicep = '{{source.asset.bin}}',
  },
}
