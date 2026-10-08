return {
  name = 'gleam',
  description = 'The Gleam compiler, formatter and language server',
  homepage = 'https://github.com/gleam-lang/gleam',
  licenses = {
    'Apache-2.0',
  },
  languages = {
    'Gleam',
  },
  categories = {
    'Formatter',
    'LSP',
  },
  -- mise installs it, as on the rest of the machine, so projects and the
  -- editor share one version; see `tools.mason-dytoy`
  source = {
    id = 'dytoy:gleam',
  },
  bin = {
    gleam = 'gleam',
  },
}
