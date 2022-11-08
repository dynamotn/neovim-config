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

M.delve = {
  mason_install = true,
  adapter = function(callback, config)
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)
    local handle
    local pid_or_err
    local host = config.host or '127.0.0.1'
    local port = config.port or '38697'
    local addr = string.format('%s:%s', host, port)

    if config.request == 'attach' and config.mode == 'remote' then
      -- Not starting delve server automatically in "Attach remote."
      -- Will connect to delve server that is listening to [host]:[port] instead.
      -- Users can use this with delve headless mode:
      --
      -- dlv debug -l 127.0.0.1:38697 --headless ./cmd/main.go
      --
      local msg = string.format("connecting to server at '%s'...", addr)
      print(msg)
    else
      local opts = {
        stdio = { nil, stdout, stderr },
        args = { 'dap', '-l', addr },
        detached = true,
      }
      handle, pid_or_err = vim.loop.spawn('dlv', opts, function(code)
        stdout:close()
        stderr:close()
        handle:close()
        if code ~= 0 then
          print('dlv exited with code', code)
        end
      end)
      assert(handle, 'Error running dlv: ' .. tostring(pid_or_err))
      stdout:read_start(function(err, chunk)
        assert(not err, err)
        if chunk then
          vim.schedule(function()
            require('dap.repl').append(chunk)
          end)
        end
      end)
      stderr:read_start(function(err, chunk)
        assert(not err, err)
        if chunk then
          vim.schedule(function()
            require('dap.repl').append(chunk)
          end)
        end
      end)
    end

    -- Wait for delve to start
    vim.defer_fn(function()
      callback({ type = 'server', host = host, port = port })
    end, 100)
  end,
  configurations = {
    {
      type = 'lldb',
      name = 'Debug',
      request = 'launch',
      program = '${file}',
    },
    {
      type = 'lldb',
      name = 'Debug (Arguments)',
      request = 'launch',
      program = '${file}',
      args = function()
        local co = coroutine.running()
        if co then
          return coroutine.create(function()
            local args = {}
            vim.ui.input({ prompt = 'Args: ' }, function(input)
              args = vim.split(input or '', ' ')
            end)
            coroutine.resume(co, args)
          end)
        else
          local args = {}
          vim.ui.input({ prompt = 'Args: ' }, function(input)
            args = vim.split(input or '', ' ')
          end)
          return args
        end
      end,
    },
    {
      type = 'lldb',
      name = 'Debug Package',
      request = 'launch',
      program = '${fileDirname}',
    },
    {
      type = 'lldb',
      name = 'Attach',
      mode = 'local',
      request = 'attach',
      processId = require('dap.utils').pick_process,
    },
    {
      type = 'lldb',
      name = 'Attach remote',
      mode = 'remote',
      request = 'attach',
    },
    {
      type = 'lldb',
      name = 'Debug test',
      request = 'launch',
      mode = 'test',
      program = '${file}',
    },
    {
      type = 'lldb',
      name = 'Debug test (go.mod)',
      request = 'launch',
      mode = 'test',
      program = './${relativeFileDirname}',
    },
  },
}

return M
