return {
  name = 'zig',
  description = 'The Zig toolchain, for the formatter it ships',
  homepage = 'https://github.com/ziglang/zig',
  licenses = {
    'MIT',
  },
  languages = {
    'Zig',
  },
  categories = {
    'Formatter',
  },
  -- mise installs it, as on the rest of the machine, so projects and the
  -- editor share one version; see `tools.mason-dytoy`
  source = {
    id = 'dytoy:zig',
  },
  bin = {
    zig = 'zig',
  },
}
