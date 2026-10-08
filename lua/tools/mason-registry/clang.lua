return {
  name = 'clang',
  description = 'C family compiler, for the clang-tidy it ships',
  homepage = 'https://github.com/llvm/llvm-project',
  licenses = {
    'Apache-2.0 WITH LLVM-exception',
  },
  languages = {
    'C',
    'C++',
  },
  categories = {
    'Linter',
  },
  -- The system package manager installs it; see `tools.mason-dytoy`
  source = {
    id = 'dytoy:clang',
  },
  bin = {
    ['clang-tidy'] = 'clang-tidy',
  },
}
