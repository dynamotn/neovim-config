return {
  ls = 'sumneko_lua',
  config = function(opts)
    opts.settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim', 'awesome' },
        },
        telemetry = {
          enable = false,
        },
        format = {
          enable = true,
          defaultConfig = {
            indent_style = 'space',
            indent_size = '2',
          },
        },
      },
    }
  end,
}
