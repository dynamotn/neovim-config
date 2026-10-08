return {
  name = 'dart',
  description = 'The Dart SDK, for the formatter it ships',
  homepage = 'https://github.com/dart-lang/sdk',
  licenses = {
    'BSD-3-Clause',
  },
  languages = {
    'Dart',
  },
  categories = {
    'Formatter',
  },
  -- mise installs it, as on the rest of the machine, so projects and the
  -- editor share one version; see `tools.mason-dytoy`
  source = {
    id = 'dytoy:dart',
  },
  bin = {
    dart = 'dart',
  },
}
