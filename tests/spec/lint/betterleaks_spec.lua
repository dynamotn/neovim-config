local h = require('helpers')

describe('lint.linters.betterleaks', function()
  local linter
  before_each(function()
    h.unload('lint.linters.betterleaks')
    vim.api.nvim_set_current_buf(h.buffer())
    linter = require('lint.linters.betterleaks')()
  end)

  it('reads the buffer from stdin and reports to stdout', function()
    assert.are.equal('betterleaks', linter.cmd)
    assert.is_true(linter.stdin)
    assert.are.equal('stdout', linter.stream)
    assert.are.equal('stdin', linter.args[1])
  end)

  it('never validates findings online and redacts them', function()
    assert.is_true(vim.list_contains(linter.args, '--validation=false'))
    assert.is_true(vim.list_contains(linter.args, '--redact'))
    assert.is_true(vim.list_contains(linter.args, '--exit-code=0'))
  end)

  it('runs from the project root of a named buffer', function()
    local dir, cleanup = h.tmpdir()
    vim.fn.mkdir(dir .. '/.git', 'p')
    h.write(dir .. '/sub/file.txt')
    vim.cmd.edit(dir .. '/sub/file.txt')
    local cwd = require('lint.linters.betterleaks')().cwd
    vim.cmd.bwipeout({ bang = true })
    cleanup()
    assert.are.equal(dir, cwd)
  end)

  it(
    'has no working directory for an unnamed buffer',
    function() assert.is_nil(linter.cwd) end
  )

  describe('parser', function()
    it('turns findings into 0-based warnings', function()
      local output = vim.json.encode({
        {
          RuleID = 'generic-api-key',
          Description = 'Generic API Key',
          StartLine = 3,
          EndLine = 3,
          StartColumn = 5,
          EndColumn = 20,
        },
      })
      assert.are.same({
        {
          bufnr = 7,
          lnum = 2,
          end_lnum = 2,
          col = 4,
          end_col = 20,
          severity = vim.diagnostic.severity.WARN,
          source = 'betterleaks',
          code = 'generic-api-key',
          message = 'Generic API Key',
        },
      }, linter.parser(output, 7))
    end)

    it(
      'is empty for an empty report',
      function() assert.are.same({}, linter.parser('[]', 1)) end
    )

    it('is empty for output that is not JSON', function()
      assert.are.same({}, linter.parser('panic: oops', 1))
      assert.are.same({}, linter.parser('', 1))
      assert.are.same({}, linter.parser('"text"', 1))
    end)
  end)
end)
