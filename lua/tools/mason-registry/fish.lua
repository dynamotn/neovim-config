return {
  name = 'fish',
  description = 'The user-friendly command line shell, with its own syntax check and formatter',
  homepage = 'https://github.com/fish-shell/fish-shell',
  licenses = {
    'GPL-2.0-only',
  },
  languages = {
    'Fish',
  },
  categories = {
    'Formatter',
    'Linter',
  },
  -- The system package manager installs it; see `tools.mason-dytoy`
  source = {
    id = 'dytoy:fish',
  },
  bin = {
    fish = 'fish',
    fish_indent = 'fish_indent',
  },
}
