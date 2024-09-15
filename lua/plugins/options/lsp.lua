local lspconfig = require('lspconfig')
local languages = require('languages')
local register_keymaps = require('plugins.register').register_keymaps
local augroup = require('core.augroup')

local default_opts = {
  autostart = true,
  on_attach = function(client, buffer)
    register_keymaps('lsp')
    augroup.enable_highlight_document(client.id)
    augroup.enable_hover(client.id)
    augroup.enable_codelens(client.id)
    augroup.enable_inlayhint(client.id)

    local present, colorizer = pcall(require, 'colorizer')
    if present then
      colorizer.attach_to_buffer(buffer)
    end
  end,
}

local configs = languages.setup_ls()
for server_name, config in pairs(configs) do
  if lspconfig[server_name] then
    default_opts.filetypes = vim.deepcopy(config.filetypes)
    local opts = config.setup(default_opts)

    local present, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    if present then
      opts.capabilities = cmp_nvim_lsp.default_capabilities(opts.capabilities)
    end

    local present, ufo = pcall(require, 'ufo')
    if present then
      opts.capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }
    end

    lspconfig[server_name].setup(opts)
  end
end
