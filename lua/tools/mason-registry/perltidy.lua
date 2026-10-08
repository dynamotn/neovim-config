return {
  name = 'perltidy',
  description = 'A formatter for Perl',
  homepage = 'https://github.com/perltidy/perltidy',
  licenses = {
    'GPL-2.0-or-later',
  },
  languages = {
    'Perl',
  },
  categories = {
    'Formatter',
  },
  -- The system package manager installs it; see `tools.mason-dytoy`
  source = {
    id = 'dytoy:perltidy',
  },
  bin = {
    perltidy = 'perltidy',
  },
}
