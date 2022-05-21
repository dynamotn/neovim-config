local present, lsp_installer = pcall(require, 'nvim-lsp-installer')

if not present then
  return
end

local present, languages = pcall(require, 'languages')

if present then
  local ls = languages.setup_ls()

  for server_name, _ in pairs(ls) do
    local server_is_found, server = lsp_installer.get_server(server_name)
    if server_is_found and not server:is_installed() then
      print('Installing ' .. server_name)
      server:install()
    end
  end

  lsp_installer.on_server_ready(function(server)
    local register_keymaps = require('plugins.register').register_keymaps
    local augroup = require('misc.augroup')

    local opts = {
      autostart = true,
      on_attach = function(client, buffer)
        register_keymaps('lsp', buffer)
        augroup.enable_highlight_document(client.id)
        augroup.enable_codelens(client.id)
        augroup.enable_codeaction(client.id)
        augroup.enable_formatting(client.id)
      end,
      on_exit = function(_, _)
        augroup.disable_highlight_document()
        augroup.disable_codeaction()
        augroup.disable_codelens()
        augroup.disable_formatting()
      end,
    }

    if ls[server.name] then
      ls[server.name].config(opts)
      opts.filetypes = ls[server.name].filetypes
    end

    local present, coq = pcall(require, 'coq')
    if present then
      server:setup(coq.lsp_ensure_capabilities(opts))
    else
      server:setup(opts)
    end
  end)
end

return lsp_installer
