return {
  cmd = { 'promql-langserver', '--config-file', 'promql-lsp.yaml' },
  filetypes = {
    'promql', -- *.promql
    'yaml', -- *.yaml (queries inside)
  },
  root_markers = { 'promql-lsp.yaml' },
}
