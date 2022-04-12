return {
    tools = {
        'luacheck',
        'stylua',
    },
    sources = function(null_ls, filetypes)
        return {
            null_ls.builtins.code_actions.refactoring.with({ filetypes = filetypes }),
            null_ls.builtins.formatting.stylua.with({ filetypes = filetypes }),
            null_ls.builtins.diagnostics.luacheck.with({ filetypes = filetypes }),
        }
    end,
}
