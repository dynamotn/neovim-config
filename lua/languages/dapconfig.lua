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

M.python = {
  mason_install = true,
  adapter = function(callback, config)
    if config.request == 'attach' then
      local port = (config.connect or config).port
      callback({
        type = 'server',
        port = assert(port, '`connect.port` is required for a python `attach` configuration'),
        host = (config.connect or config).host or '127.0.0.1',
      })
    else
      callback({
        type = 'executable',
        command = 'python',
        args = { '-m', 'debugpy.adapter' },
      })
    end
  end,
  configurations = {
    {
      type = 'python',
      request = 'launch',
      name = 'Launch file',
      program = '${file}',
      args = function()
        local args_string = vim.fn.input('Arguments: ')
        return vim.split(args_string, ' +')
      end,
    },
    {
      type = 'python',
      request = 'attach',
      name = 'Attach remote',
      connect = function()
        local host = vim.fn.input('Host [127.0.0.1]: ')
        host = host ~= '' and host or '127.0.0.1'
        local port = tonumber(vim.fn.input('Port [5678]: ')) or 5678
        return { host = host, port = port }
      end,
    },
    {
      {
        type = 'python',
        request = 'launch',
        name = 'Run doctests in file',
        module = 'doctest',
        args = { '${file}' },
        noDebug = true,
      },
    },
  },
}

M.ruby = {
  mason_install = false,
  adapter = function(callback, config)
    local handle
    local stdout = vim.loop.new_pipe(false)
    local pid_or_err
    local waiting = config.waiting or 500
    local args
    local script
    local rdbg

    if config.current_line then
      script = config.script .. ':' .. vim.fn.line('.')
    else
      script = config.script
    end

    if config.bundle == 'bundle' then
      args = { '-n', '--open', '--port', config.port, '-c', '--', 'bundle', 'exec', config.command, script }
    else
      args = { '--open', '--port', config.port, '-c', '--', config.command, script }
    end

    local opts = {
      stdio = { nil, stdout },
      args = args,
      detached = false,
    }

    if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
      rdbg = 'rdbg.bat'
    else
      rdbg = 'rdbg'
    end

    handle, pid_or_err = vim.loop.spawn(rdbg, opts, function(code)
      handle:close()
      if code ~= 0 then
        assert(handle, 'rdbg exited with code: ' .. tostring(code))
        print('rdbg exited with code', code)
      end
    end)

    assert(handle, 'Error running rgdb: ' .. tostring(pid_or_err))

    stdout:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        vim.schedule(function()
          require('dap.repl').append(chunk)
        end)
      end
    end)

    -- Wait for rdbg to start
    vim.defer_fn(function()
      callback({ type = 'server', host = config.server, port = config.port })
    end, waiting)
  end,
  configurations = {
    {
      type = 'ruby',
      name = 'Debug current file',
      bundle = '',
      request = 'attach',
      command = 'ruby',
      script = '${file}',
      port = 38698,
      server = '127.0.0.1',
      localfs = true,
      waiting = 1000,
    },
    {
      type = 'ruby',
      name = 'Run rspec current_file',
      bundle = 'bundle',
      request = 'attach',
      command = 'rspec',
      script = '${file}',
      port = 38698,
      server = '127.0.0.1',
      localfs = true,
      waiting = 1000,
    },
    {
      type = 'ruby',
      name = 'Run rspec current_file:current_line',
      bundle = 'bundle',
      request = 'attach',
      command = 'rspec',
      script = '${file}',
      port = 38698,
      server = '127.0.0.1',
      localfs = true,
      waiting = 1000,
      current_line = true,
    },
    {
      type = 'ruby',
      name = 'Run rspec',
      bundle = 'bundle',
      request = 'attach',
      command = 'rspec',
      script = './spec',
      port = 38698,
      server = '127.0.0.1',
      localfs = true,
      waiting = 1000,
    },
  },
}

return M
