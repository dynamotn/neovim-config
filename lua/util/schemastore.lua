local M = {}

--- Get YAML schema name from catalog of SchemaStore from URI
---@param uri string URI of schame
M.get_yaml_schema_name = function(uri)
  local catalog = require('schemastore').json.load()
  for _, schema in ipairs(catalog.schemas) do
    if schema.url == uri then return schema.name end
  end
  return 'Custom'
end

return M
