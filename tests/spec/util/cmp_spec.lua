local h = require('helpers')

describe('util.cmp', function()
  local cmp, env_backup, restore_executable, executables

  local pane_vars = {
    'KITTY_LISTEN_ON',
    'KITTY_WINDOW_ID',
    'TMUX',
    'ZELLIJ',
    'ZELLIJ_SESSION_NAME',
  }

  before_each(function()
    env_backup = {}
    for _, var in ipairs(pane_vars) do
      env_backup[var] = vim.env[var]
      vim.env[var] = nil
    end
    executables = {}
    restore_executable = h.stub(
      vim.fn,
      'executable',
      function(name) return executables[name] and 1 or 0 end
    )
    h.unload('util.cmp')
    cmp = require('util.cmp')
  end)
  after_each(function()
    restore_executable()
    for _, var in ipairs(pane_vars) do
      vim.env[var] = env_backup[var]
    end
  end)

  local common = {
    'lsp',
    'path',
    'project_path',
    'fuzzy_path',
    'snippets',
    'buffer',
    'calc',
    'emoji',
    'dynamic',
    'dictionary',
  }

  describe('sources', function()
    it(
      'gives the common sources for *',
      function() assert.same(common, cmp.sources('*')) end
    )

    it(
      'gives the comment sources',
      function()
        assert.same(
          { 'buffer', 'ripgrep', 'dictionary', 'emoji', 'nerdfont', 'dynamic' },
          cmp.sources('comment')
        )
      end
    )

    it(
      'gives the dap sources',
      function() assert.same({ 'dap', 'buffer', 'ripgrep' }, cmp.sources('dap')) end
    )

    for _, ft in ipairs({ 'gitcommit', 'gitrebase', 'octo' }) do
      it('gives git sources for ' .. ft, function()
        local sources = cmp.sources(ft)
        assert.equals('git', sources[1])
        assert.is_false(vim.list_contains(sources, 'path'))
      end)
    end

    for ft, unique in pairs({
      markdown = { 'nerdfont' },
      typst = { 'nerdfont' },
      blade = { 'blade-nav', 'laravel' },
      clojure = { 'conjure' },
      fish = { 'fish' },
      julia = { 'latex_symbols' },
      r = { 'cmp_r' },
      sql = { 'dadbod', 'sql' },
      lua = { 'lazydev' },
    }) do
      it(
        'puts the own sources of ' .. ft .. ' first',
        function()
          assert.same(
            vim.list_extend(vim.deepcopy(unique), common),
            cmp.sources(ft)
          )
        end
      )
    end

    it(
      'gives nothing for a filetype it does not know',
      function() assert.is_nil(cmp.sources('rust')) end
    )
  end)

  describe('pane sources', function()
    local dir, cleanup, server
    before_each(function()
      dir, cleanup = h.tmpdir()
    end)
    after_each(function()
      if server then
        server:close()
        server = nil
      end
      cleanup()
    end)

    local function socket(path)
      server = vim.uv.new_pipe(false)
      assert(server:bind(path))
      return path
    end

    it('adds zellij when its session is set and the binary exists', function()
      vim.env.ZELLIJ, vim.env.ZELLIJ_SESSION_NAME = '0', 'main'
      assert.is_false(vim.list_contains(cmp.sources('*'), 'zellij'))
      executables.zellij = true
      assert.is_true(vim.list_contains(cmp.sources('*'), 'zellij'))
    end)

    it('adds tmux only when its socket is alive', function()
      executables.tmux = true
      vim.env.TMUX = dir .. '/missing,1,0'
      assert.is_false(vim.list_contains(cmp.sources('*'), 'tmux'))
      vim.env.TMUX = socket(dir .. '/tmux.sock') .. ',1,0'
      assert.is_true(vim.list_contains(cmp.sources('*'), 'tmux'))
    end)

    it('adds kitty for a live socket, an abstract one, or TCP', function()
      executables.kitty = true
      vim.env.KITTY_WINDOW_ID = '1'
      vim.env.KITTY_LISTEN_ON = 'unix:' .. dir .. '/missing'
      assert.is_false(vim.list_contains(cmp.sources('*'), 'kitty'))
      vim.env.KITTY_LISTEN_ON = 'unix:' .. socket(dir .. '/kitty.sock')
      assert.is_true(vim.list_contains(cmp.sources('*'), 'kitty'))
      vim.env.KITTY_LISTEN_ON = 'unix:@kitty'
      assert.is_true(vim.list_contains(cmp.sources('*'), 'kitty'))
      vim.env.KITTY_LISTEN_ON = 'tcp:localhost:1234'
      assert.is_true(vim.list_contains(cmp.sources('*'), 'kitty'))
    end)

    it('leaves kitty out without a window id or binary', function()
      vim.env.KITTY_LISTEN_ON = 'unix:@kitty'
      executables.kitty = true
      assert.is_false(vim.list_contains(cmp.sources('*'), 'kitty'))
      vim.env.KITTY_WINDOW_ID = '1'
      executables.kitty = nil
      assert.is_false(vim.list_contains(cmp.sources('*'), 'kitty'))
    end)
  end)

  describe('setup_default_sources', function()
    local restore
    after_each(function() restore() end)

    it('gives comment sources inside a comment node', function()
      restore = h.stub(vim.treesitter, 'get_node', function()
        return { type = function() return 'line_comment' end }
      end)
      assert.same(cmp.sources('comment'), cmp.setup_default_sources())
    end)

    it('gives common sources elsewhere', function()
      restore = h.stub(vim.treesitter, 'get_node', function()
        return { type = function() return 'identifier' end }
      end)
      assert.same(common, cmp.setup_default_sources())
    end)

    it('gives common sources when there is no parser', function()
      restore = h.stub(
        vim.treesitter,
        'get_node',
        function() error('no parser') end
      )
      assert.same(common, cmp.setup_default_sources())
    end)
  end)
end)
