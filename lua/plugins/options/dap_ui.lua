local dap_ui = require('dapui')

dap_ui.setup({})

local dap = require('dap')
dap.listeners.after.event_initialized['dapui_config'] = function()
  dap_ui.open()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
  dap_ui.close()
end
dap.listeners.before.event_exited['dapui_config'] = function()
  dap_ui.close()
end
