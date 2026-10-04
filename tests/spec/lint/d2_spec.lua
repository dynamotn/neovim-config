local h = require('helpers')

-- `lint.parser` belongs to nvim-lint, taken from lazy.nvim's install
-- directory when this machine has it.
local nvim_lint = vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy', 'nvim-lint')
local has_lint = vim.uv.fs_stat(nvim_lint) ~= nil
if has_lint then vim.opt.rtp:append(nvim_lint) end

describe('lint.linters.d2', function()
  if not has_lint then
    pending('nvim-lint is not installed')
    return
  end

  local linter
  before_each(function()
    h.unload('lint.linters.d2')
    linter = require('lint.linters.d2')
  end)

  it('validates the buffer from stdin', function()
    assert.are.equal('d2', linter.cmd)
    assert.is_true(linter.stdin)
    assert.are.same({ 'validate', '-' }, linter.args)
    assert.are.equal('stderr', linter.stream)
    assert.is_true(linter.ignore_exitcode)
  end)

  it('parses both shapes of error line', function()
    local bufnr = h.buffer({ lines = { 'a', 'b', 'c', 'd', 'x -> ', 'y' } })
    local output = table.concat({
      'err: github.com/d2lang/d2/d2cli.validateCmd: 5:1: connection missing destination',
      'err: 6:5: unexpected text after map key',
      'success: nothing',
    }, '\n')
    local diagnostics = linter.parser(output, bufnr)
    assert.are.equal(2, #diagnostics)
    assert.are.equal(4, diagnostics[1].lnum)
    assert.are.equal(0, diagnostics[1].col)
    assert.are.equal('connection missing destination', diagnostics[1].message)
    assert.are.equal(vim.diagnostic.severity.ERROR, diagnostics[1].severity)
    assert.are.equal('d2', diagnostics[1].source)
    assert.are.equal(5, diagnostics[2].lnum)
    assert.are.equal(4, diagnostics[2].col)
    assert.are.equal('unexpected text after map key', diagnostics[2].message)
  end)

  it(
    'is empty for a valid diagram',
    function() assert.are.same({}, linter.parser('', h.buffer())) end
  )
end)
