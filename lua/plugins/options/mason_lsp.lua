local mason_lsp_config = require('mason-lspconfig')
local languages = require('languages')

local servers = {}
for _, language in ipairs(DEFAULT_ENABLED_LANGUAGES) do
  servers = vim.tbl_extend('force', servers, languages.get_ls_by_language(language))
end

mason_lsp_config.setup({
  ensure_installed = servers,
})
