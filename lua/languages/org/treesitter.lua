return {
  {
    parser = 'norg',
  },
  {
    parser = 'norg_meta',
    install_info = {
      url = 'https://github.com/nvim-neorg/tree-sitter-norg-meta',
      branch = 'main',
      files = { 'src/parser.c' },
    },
  },
}
