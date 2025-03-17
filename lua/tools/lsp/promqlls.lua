local util = require('lspconfig.util')

return {
  default_config = {
    cmd = { 'promql-langserver', '--config-file', 'promql-lsp.yaml' },
    filetypes = {
      'promql', -- *.promql
      'yaml', -- *.yaml (queries inside)
    },
    root_dir = function(fname, _)
      return util.root_pattern({ 'promql-lsp.yaml', '.git' })(fname)
    end,
    single_file_support = true,
  },
  docs = {
    description = [[
PromQL language server is a language server that allow to connect Prometheus server to get queries with label and metric data.

You can install `promqlls` using mason or follow the instructions here: https://github.com/prometheus-community/promql-langserver

Rememmber to create `promql-lsp.yaml` in your project with these information before run:
```
# Change this address to the address of the prometheus server you want to use for metadata
prometheus_url: http://localhost:9090
rpc_trace: text
```

]],
  },
}
