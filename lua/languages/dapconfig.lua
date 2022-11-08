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

local BASHDB_DIR = require('mason-registry').get_package('bash-debug-adapter'):get_install_path()
  .. '/extension/bashdb_dir'
M.bash = {
  mason_install = true,
  adapter = {
    type = 'executable',
    command = 'bash-debug-adapter',
  },
  configurations = {
    {
      type = 'bash',
      request = 'launch',
      name = 'Bash: Launch file',
      program = '${file}',
      cwd = '${fileDirname}',
      pathBashdb = BASHDB_DIR .. '/bashdb',
      pathBashdbLib = BASHDB_DIR,
      pathBash = 'bash',
      pathCat = 'cat',
      pathMkfifo = 'mkfifo',
      pathPkill = 'pkill',
      env = {},
      args = {},
    },
  },
}

M.lldb = {
  mason_install = true,
  adapter = {
    type = 'server',
    host = '127.0.0.1',
    port = '${port}',
    executable = {
      command = 'codelldb',
      args = { '--port', '${port}' },
    },
  },
  configurations = {
    {
      name = 'Launch file',
      type = 'lldb',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = true,
    },
  },
}

return M
