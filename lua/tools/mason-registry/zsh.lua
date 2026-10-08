return {
  name = 'zsh',
  description = 'The Z shell, for its own syntax check',
  homepage = 'https://github.com/zsh-users/zsh',
  licenses = {
    'MIT-Modern-Variant',
  },
  languages = {
    'Zsh',
  },
  categories = {
    'Linter',
  },
  -- The system package manager installs it; see `tools.mason-dytoy`
  source = {
    id = 'dytoy:zsh',
  },
  bin = {
    zsh = 'zsh',
  },
}
