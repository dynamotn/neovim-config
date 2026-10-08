return {
  name = 'nufmt',
  description = 'The formatter for Nushell',
  homepage = 'https://github.com/nushell/nufmt',
  licenses = {
    'MIT',
  },
  languages = {
    'Nushell',
  },
  categories = {
    'Formatter',
  },
  -- Not on crates.io and never tagged, so a commit of its repository is
  -- pinned; building it needs `cargo`, which dytoy installs (`dytoy --tool
  -- rust`)
  source = {
    id = 'pkg:cargo/nufmt@f279091abd66c5d20838f1c5601f5be758b122e1?repository_url=https://github.com/nushell/nufmt&rev=true',
  },
  bin = {
    nufmt = 'cargo:nufmt',
  },
}
