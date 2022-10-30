local lspconfig = require('lspconfig')
local languages = require('languages')
local register_keymaps = require('plugins.register').register_keymaps
local augroup = require('misc.augroup')

local default_opts = {
  autostart = true,
  capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    return capabilities
  end,
  on_attach = function(client, buffer)
    register_keymaps('lsp', buffer)
    augroup.enable_highlight_document(client.id)
    augroup.enable_codelens(client.id)
    augroup.enable_codeaction(client.id)
    augroup.enable_formatting(client.id)
    local present, navic = pcall(require, 'nvim-navic')
    if present and client.server_capabilities.documentSymbolProvider then
      navic.attach(client, buffer)
    end

    local present, colorizer = pcall(require, 'colorizer')
    if present then
      colorizer.attach_to_buffer(buffer)
    end
  end,
  on_exit = function(_, _)
    augroup.disable_highlight_document()
    augroup.disable_codeaction()
    augroup.disable_codelens()
    augroup.disable_formatting()
  end,
}

local configs = languages.setup_ls()
for server_name, config in pairs(configs) do
  if lspconfig[server_name] then
    local opts = config.setup(default_opts)
    opts.filetypes = config.filetypes

    local present, coq = pcall(require, 'coq')
    if present then
      lspconfig[server_name].setup(coq.lsp_ensure_capabilities(opts))
    else
      lspconfig[server_name].setup(opts)
    end
  end
end
