local h = require('helpers')

describe('util.blink', function()
  local blink

  before_each(function()
    h.unload('util.blink')
    blink = require('util.blink')
  end)

  describe('map', function()
    it('runs the actions in turn until one handles the key', function()
      local ran = {}
      blink.actions.first = function()
        table.insert(ran, 'first')
        return false
      end
      blink.actions.second = function()
        table.insert(ran, 'second')
        return true
      end
      blink.actions.third = function() table.insert(ran, 'third') end
      assert.is_true(blink.map({ 'first', 'second', 'third' })())
      assert.are.same({ 'first', 'second' }, ran)
    end)

    it(
      'skips an action nothing has registered',
      function() assert.are.equal('<tab>', blink.map({ 'ai_nes' }, '<tab>')()) end
    )

    it('calls a fallback function when no action handles the key', function()
      local called = false
      blink.map({}, function()
        called = true
        return 'fell back'
      end)()
      assert.is_true(called)
    end)
  end)

  describe('snippets', function()
    it(
      'flattens nested placeholders',
      function()
        assert.are.equal(
          '${1:foo(bar)}',
          blink.snippet_fix('${1:foo(${2:bar})}')
        )
      end
    )

    it(
      'leaves a flat snippet alone',
      function()
        assert.are.equal('print(${1:x})', blink.snippet_fix('print(${1:x})'))
      end
    )

    it(
      'previews a snippet as the text it inserts',
      function()
        assert.are.equal('foo(bar)', blink.snippet_preview('foo(${1:bar})$0'))
      end
    )

    it('falls back on the flattened snippet when expanding fails', function()
      local expanded, warned = {}, {}
      local restores = {
        h.stub(vim.snippet, 'expand', function(snippet)
          table.insert(expanded, snippet)
          if #expanded == 1 then error('nested') end
        end),
        h.stub(
          require('util.plugin'),
          'warn',
          function(msg) table.insert(warned, msg) end
        ),
      }
      blink.expand('${1:foo(${2:bar})}')
      for i = #restores, 1, -1 do
        restores[i]()
      end
      assert.are.same({ '${1:foo(${2:bar})}', '${1:foo(bar)}' }, expanded)
      assert.are.equal(1, #warned)
    end)
  end)
end)
