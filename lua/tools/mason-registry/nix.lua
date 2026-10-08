return {
  name = 'nix',
  description = 'The Nix package manager, for the parser it checks Nix files with',
  homepage = 'https://github.com/NixOS/nix',
  licenses = {
    'LGPL-2.1-only',
  },
  languages = {
    'Nix',
  },
  categories = {
    'Linter',
  },
  -- The system package manager installs it; see `tools.mason-dytoy`
  source = {
    id = 'dytoy:nix',
  },
  bin = {
    nix = 'nix',
  },
}
