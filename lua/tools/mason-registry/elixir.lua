return {
  name = 'elixir',
  description = 'The Elixir language, for the mix tasks that lint and format it',
  homepage = 'https://github.com/elixir-lang/elixir',
  licenses = {
    'Apache-2.0',
  },
  languages = {
    'Elixir',
  },
  categories = {
    'Formatter',
    'Linter',
  },
  -- The system package manager installs it; see `tools.mason-dytoy`
  source = {
    id = 'dytoy:elixir',
  },
  bin = {
    mix = 'mix',
  },
}
