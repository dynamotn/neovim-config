return {
  ls = 'yamlls',
  config = function(opts)
    opts.settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = {
        validate = true,
        format = {
          enable = true,
        },
        hover = true,
        schemaStore = {
          enable = true,
          url = 'https://www.schemastore.org/api/json/catalog.json',
        },
        schemaDownload = {
          enable = true,
        },
        schemas = {},
        trace = { server = 'debug' },
      },
    }
  end,
}
