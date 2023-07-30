local dap = require('dap')
local configs = require('languages').setup_dap()

for server_name, config in pairs(configs) do
  dap.adapters[server_name] = config.adapter

  for _, filetype in ipairs(config.filetypes) do
    dap.configurations[filetype] = config.configurations
  end
end

for name, sign in pairs(require('core.defaults').icons.dap) do
  name = 'Dap' .. name
  vim.fn.sign_define(name, { text = sign[1], texthl = sign[2] or 'DiagnosticInfo', linehl = sign[3], numhl = sign[3] })
end
