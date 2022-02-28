return {
    ls = 'sumneko_lua',
    config = function(opts)
        opts.settings = {
            Lua = {
                diagnostics = {
                    globals = { 'vim' },
                },
                telemetry = {
                    enable = false,
                },
            },
        }
    end,
}
