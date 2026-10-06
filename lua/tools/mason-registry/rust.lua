return {
  name = 'rust',
  description = 'The Rust toolchain, for the rustfmt it ships',
  homepage = 'https://github.com/rust-lang/rust',
  licenses = {
    'MIT',
    'Apache-2.0',
  },
  languages = {
    'Rust',
  },
  categories = {
    'Formatter',
  },
  -- mise installs the toolchain, as on the rest of the machine; see
  -- `tools.mason-dytoy`
  source = {
    id = 'dytoy:rust',
  },
  bin = {
    rustfmt = 'rustfmt',
  },
}
