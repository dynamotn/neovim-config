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
        local opts = {
            autostart = true,
            on_attach = function(_, buffer)
                register_keymaps('lsp', buffer)
            end,
        }

        if ls[server.name] then
            ls[server.name](opts)
        end

        server:setup(opts)
    end)
end

return lsp_installer
