return {
  {
    parser = 'norg',
    install_info = {
      url = 'https://github.com/nvim-neorg/tree-sitter-norg',
      branch = 'main',
      files = { 'src/parser.c', 'src/scanner.cc' },
      cxx_standard = 'c++14',
      use_makefile = true,
    },
  },
  {
    parser = 'norg_meta',
    install_info = {
      url = 'https://github.com/nvim-neorg/tree-sitter-norg-meta',
      branch = 'main',
      files = { 'src/parser.c' },
      cxx_standard = 'c++14',
      use_makefile = true,
    },
  },
}
