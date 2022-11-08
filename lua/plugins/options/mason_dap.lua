local present, mason_dap_config = pcall(require, 'mason-nvim-dap')

if not present then
  return
end

local configs = require('languages').setup_dap()
local dap_servers = {}

for server_name, config in pairs(configs) do
  if config.mason_install then
    table.insert(dap_servers, server_name)
  end
end

mason_dap_config.setup({
  ensure_installed = dap_servers,
  automatic_setup = true,
})

mason_dap_config.setup_handlers({
  function(source_name)
    require('mason-nvim-dap.automatic_setup')(source_name)
  end,
})
