return {
  name = 'perlcritic',
  description = 'A static analyzer for Perl, based on Perl Best Practices',
  homepage = 'https://github.com/Perl-Critic/Perl-Critic',
  licenses = {
    'Artistic-1.0-Perl',
    'GPL-1.0-or-later',
  },
  languages = {
    'Perl',
  },
  categories = {
    'Linter',
  },
  -- The system package manager installs it; see `tools.mason-dytoy`
  source = {
    id = 'dytoy:perlcritic',
  },
  bin = {
    perlcritic = 'perlcritic',
  },
}
