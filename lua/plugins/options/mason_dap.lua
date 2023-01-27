local mason_dap_config = require('mason-nvim-dap')

mason_dap_config.setup({
  automatic_setup = true,
  automatic_installation = true,
})

mason_dap_config.setup_handlers({
  function(source_name)
    require('mason-nvim-dap.automatic_setup')(source_name)
  end,
})
