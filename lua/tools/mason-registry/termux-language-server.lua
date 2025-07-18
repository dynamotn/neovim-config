return {
  name = 'termux-language-server',
  description = 'A language server for some specific bash scripts.',
  homepage = 'https://termux-language-server.readthedocs.io/en/latest/',
  licenses = {
    'GPL-3.0',
  },
  languages = {
    'Bash',
  },
  categories = {
    'LSP',
  },
  source = {
    id = 'pkg:pypi/termux-language-server@0.0.27',
  },
  bin = {
    ['termux-language-server'] = 'pypi:termux-language-server',
  },
  neovim = {
    lspconfig = 'termuxls',
  },
}
