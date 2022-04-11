return {
    tools = {
        'shellcheck',
        'shfmt',
        'shellharden',
    },
    sources = function(null_ls, filetypes)
        return {
            null_ls.builtins.code_actions.shellcheck.with({ filetypes = filetypes }),
            null_ls.builtins.diagnostics.shellcheck.with({ filetypes = filetypes }),
            null_ls.builtins.formatting.shfmt.with({
                filetypes = filetypes,
                extra_args = { '-i', '2', '-ci', '-bn', '-sr' },
            }),
            null_ls.builtins.formatting.shellharden.with({ filetypes = filetypes }),
        }
    end,
}
