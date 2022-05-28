local M = {}

M.sumneko_lua = function(opts)
  opts.settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim', 'awesome' },
      },
      telemetry = {
        enable = false,
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = 'space',
          indent_size = '2',
        },
      },
    },
  }
  return opts
end

M.yamlls = function(opts)
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
  return opts
end

return M
