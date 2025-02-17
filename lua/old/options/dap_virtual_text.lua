local dap_virtual_text = require('nvim-dap-virtual-text')

dap_virtual_text.setup({})

local dap = require('dap')
dap.listeners.after.event_initialized['dap_virtual_text'] = function()
  dap_virtual_text.enable()
end
dap.listeners.before.event_terminated['dap_virtual_text'] = function()
  dap_virtual_text.disable()
end
