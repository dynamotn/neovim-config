local present, dap = pcall(require, 'dap')

if not present then
  return
end

local configs = require('languages').setup_dap()

for server_name, config in pairs(configs) do
  dap.adapters[server_name] = config.adapter

  for _, filetype in ipairs(config.filetypes) do
    dap.configurations[filetype] = config.configurations
  end
end
