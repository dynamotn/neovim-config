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
    -- A commit, not `master`: a moving branch would install whatever was
    -- pushed last, past the quarantine and never the same twice. v0.6.0
    -- predates the fixes on `master`, so its commit of 2026-09-01 is pinned.
    id = 'pkg:golang/github.com/prometheus-community/promql-langserver@v0.6.1-0.20260901061211-16207ce33aa5#cmd/promql-langserver',
  },
  bin = {
    ['promql-langserver'] = 'golang:promql-langserver',
  },
  neovim = {
    lspconfig = 'promqlls',
  },
}
