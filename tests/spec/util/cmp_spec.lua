local h = require('helpers')

describe('util.cmp', function()
  local cmp, env_backup, restore_executable, executables

  local pane_vars = { 'TMUX' }

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
    -- They say themselves whether their session or socket is there
    'zellij',
    'kitty',
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

    it('leaves zellij and kitty to say whether they are reachable', function()
      local sources = cmp.sources('*')
      assert.is_true(vim.list_contains(sources, 'zellij'))
      assert.is_true(vim.list_contains(sources, 'kitty'))
    end)

    it('adds tmux only when its socket is alive', function()
      executables.tmux = true
      vim.env.TMUX = dir .. '/missing,1,0'
      assert.is_false(vim.list_contains(cmp.sources('*'), 'tmux'))
      vim.env.TMUX = socket(dir .. '/tmux.sock') .. ',1,0'
      assert.is_true(vim.list_contains(cmp.sources('*'), 'tmux'))
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

describe('util.cmp on the command line', function()
  local cmp, restore, cmdtype, path_completion, asked

  before_each(function()
    cmdtype, path_completion, asked = ':', false, nil
    restore = {
      h.stub(vim.fn, 'getcmdtype', function() return cmdtype end),
      h.stub(vim.fn, 'getcmdline', function() return 'e lua/' end),
    }
    -- blink's own cmdline helpers, which decide when its `cmdline` source
    -- completes a path
    package.loaded['blink.cmp.sources.cmdline.utils'] = {
      get_completion_type = function(mode)
        asked = mode
        return path_completion and 'file' or 'command'
      end,
      is_path_completion = function(completion_type, line)
        return completion_type == 'file' and line == 'e lua/'
      end,
    }
    h.unload('util.cmp')
    cmp = require('util.cmp')
  end)

  after_each(function()
    for i = #restore, 1, -1 do
      restore[i]()
    end
    h.unload('blink.cmp.sources.cmdline.utils')
  end)

  describe('cmdline_sources', function()
    it(
      'keeps `path` while `cmdline` completes no path',
      function()
        assert.same(
          { 'cmdline', 'fuzzy_path', 'path', 'buffer' },
          cmp.cmdline_sources()
        )
      end
    )

    it('drops `path` where `cmdline` lists the directory itself', function()
      path_completion = true
      assert.same({ 'cmdline', 'fuzzy_path', 'buffer' }, cmp.cmdline_sources())
      assert.equals('cmdline', asked)
    end)

    it('completes a search from the buffers alone', function()
      cmdtype = '/'
      assert.same({ 'buffer' }, cmp.cmdline_sources())
      cmdtype = '?'
      assert.same({ 'buffer' }, cmp.cmdline_sources())
    end)

    it('completes nothing on other command lines', function()
      cmdtype = '='
      assert.same({}, cmp.cmdline_sources())
    end)

    it('keeps `path` when blink cannot say', function()
      path_completion = true
      package.loaded['blink.cmp.sources.cmdline.utils'] = nil
      local searchers = package.loaders or package.searchers
      table.insert(searchers, 1, function(name)
        if name == 'blink.cmp.sources.cmdline.utils' then
          return function() error('not here') end
        end
      end)
      local ok, result = pcall(cmp.cmdline_sources)
      table.remove(searchers, 1)
      assert.is_true(ok)
      assert.same({ 'cmdline', 'fuzzy_path', 'path', 'buffer' }, result)
    end)
  end)
end)
