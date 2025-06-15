return {
  name = 'promql-langserver',
  description = 'PromQL Language Server.',
  homepage = 'https://github.com/prometheus-community/promql-langserver',
  licenses = {
    'Apache-2.0',
  },
  languages = {
    'PromQL',
  },
  categories = {
    'LSP',
  },
  source = {
    id = 'pkg:golang/github.com/prometheus-community/promql-langserver@master#cmd/promql-langserver',
  },
  bin = {
    ['promql-langserver'] = 'golang:promql-langserver',
  },
  neovim = {
    lspconfig = 'promqlls',
  },
}
