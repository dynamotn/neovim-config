return {
  name = 'erlfmt',
  description = 'An automated code formatter for Erlang',
  homepage = 'https://github.com/WhatsApp/erlfmt',
  licenses = {
    'Apache-2.0',
  },
  languages = {
    'Erlang',
  },
  categories = {
    'Formatter',
  },
  -- No release ships the escript, so it is built from the tagged source; that
  -- needs `rebar3` and Erlang, which dytoy installs (`dytoy --tool erlang`)
  source = {
    id = 'pkg:github/WhatsApp/erlfmt@v1.8.0',
    build = {
      target = 'unix',
      run = '</dev/null rebar3 as release escriptize\n',
      erlfmt = '_build/release/bin/erlfmt',
    },
  },
  bin = {
    erlfmt = '{{source.build.erlfmt}}',
  },
}
