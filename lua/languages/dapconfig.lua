local M = {}

M.neovim = {
  mason_install = false,
  adapter = function(callback, config)
    callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
  end,
  configurations = {
    {
      type = 'neovim',
      request = 'attach',
      name = 'Attach to running Neovim instance',
    },
  },
}

return M
