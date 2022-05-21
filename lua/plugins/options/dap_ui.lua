local present, dap_ui = pcall(require, 'dapui')

if not present then
  return
end

dap_ui.setup({
  sidebar = {
    position = 'right',
  },
})

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
