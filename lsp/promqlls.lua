return {
  cmd = { 'promql-langserver', '--config-file', 'promql-lsp.yaml' },
  filetypes = {
    'promql', -- *.promql
    'yaml', -- *.yaml (queries inside)
  },
  root_markers = { 'promql-lsp.yaml' },
  -- The config file is read from the root, and the server exits without
  -- one; it used to start, and die, on every other YAML buffer
  workspace_required = true,
}
