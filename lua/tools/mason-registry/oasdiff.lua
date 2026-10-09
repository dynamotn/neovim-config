return {
  name = 'oasdiff',
  description = 'Compare OpenAPI specs, and tell the breaking changes',
  homepage = 'https://www.oasdiff.com',
  licenses = {
    'Apache-2.0',
  },
  languages = {
    'OpenAPI',
  },
  categories = {
    'Linter',
  },
  source = {
    id = 'pkg:github/oasdiff/oasdiff@v1.33.0',
    asset = {
      {
        target = 'darwin_arm64',
        file = 'oasdiff_{{ version | strip_prefix "v" }}_darwin_all.tar.gz',
        bin = 'oasdiff',
      },
      {
        target = 'darwin_x64',
        file = 'oasdiff_{{ version | strip_prefix "v" }}_darwin_all.tar.gz',
        bin = 'oasdiff',
      },
      {
        target = 'linux_arm64',
        file = 'oasdiff_{{ version | strip_prefix "v" }}_linux_arm64.tar.gz',
        bin = 'oasdiff',
      },
      {
        target = 'linux_x64',
        file = 'oasdiff_{{ version | strip_prefix "v" }}_linux_amd64.tar.gz',
        bin = 'oasdiff',
      },
    },
  },
  bin = {
    oasdiff = '{{source.asset.bin}}',
  },
}
