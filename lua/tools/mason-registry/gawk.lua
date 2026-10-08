return {
  name = 'gawk',
  description = 'The GNU implementation of awk, which lints and pretty-prints awk',
  homepage = 'https://www.gnu.org/software/gawk/',
  licenses = {
    'GPL-3.0-or-later',
  },
  languages = {
    'Awk',
  },
  categories = {
    'Formatter',
    'Linter',
  },
  -- The system package manager installs it; see `tools.mason-dytoy`
  source = {
    id = 'dytoy:gawk',
  },
  bin = {
    gawk = 'gawk',
  },
}
