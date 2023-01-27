local dap = require('dap')
local configs = require('languages').setup_dap()

for server_name, config in pairs(configs) do
  dap.adapters[server_name] = config.adapter

  for _, filetype in ipairs(config.filetypes) do
    dap.configurations[filetype] = config.configurations
  end
end
