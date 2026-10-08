local h = require('helpers')

describe('util.blink', function()
  local blink, restore, cmdtype, path_completion, asked

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
    h.unload('util.blink')
    blink = require('util.blink')
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
          blink.cmdline_sources()
        )
      end
    )

    it('drops `path` where `cmdline` lists the directory itself', function()
      path_completion = true
      assert.same(
        { 'cmdline', 'fuzzy_path', 'buffer' },
        blink.cmdline_sources()
      )
      assert.equals('cmdline', asked)
    end)

    it('completes a search from the buffers alone', function()
      cmdtype = '/'
      assert.same({ 'buffer' }, blink.cmdline_sources())
      cmdtype = '?'
      assert.same({ 'buffer' }, blink.cmdline_sources())
    end)

    it('completes nothing on other command lines', function()
      cmdtype = '='
      assert.same({}, blink.cmdline_sources())
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
      local ok, result = pcall(blink.cmdline_sources)
      table.remove(searchers, 1)
      assert.is_true(ok)
      assert.same({ 'cmdline', 'fuzzy_path', 'path', 'buffer' }, result)
    end)
  end)
end)
