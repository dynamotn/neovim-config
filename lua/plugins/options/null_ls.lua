local present, null_ls = pcall(require, 'null-ls')

if not present then
    return
end

local present, languages = pcall(require, 'languages')

if present then
    local augroup = require('misc.augroup')
    local sources = languages.setup_null_ls(null_ls)

    table.insert(sources, null_ls.builtins.diagnostics.trail_space)
    table.insert(sources, null_ls.builtins.formatting.trim_whitespace)
    table.insert(sources, null_ls.builtins.formatting.trim_newlines)

    null_ls.setup({
        sources = sources,
        on_attach = function(client)
            augroup.enable_codeaction(client.id)
            augroup.enable_formatting(client.id)
        end,
        on_exit = function(_)
            augroup.disable_codeaction()
            augroup.disable_formatting()
        end,
    })
end
