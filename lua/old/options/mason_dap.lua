local mason_dap_config = require('mason-nvim-dap')
local languages = require('languages')

local servers = {}
for _, language in ipairs(DEFAULT_ENABLED_LANGUAGES) do
  servers = vim.tbl_extend('force', servers, languages.get_dap_by_language(language))
end

mason_dap_config.setup({
  ensure_installed = servers,
})
