local h = require('helpers')

describe('util.system', function()
  local system, dir, cleanup
  before_each(function()
    h.unload('util.system')
    system = require('util.system')
    dir, cleanup = h.tmpdir()
  end)
  after_each(function() cleanup() end)

  it('hands back what the command said', function()
    local result = system.sync(
      { 'sh', '-c', 'echo out; echo err >&2; exit 3' },
      {
        text = true,
      }
    )
    assert.are.equal(3, result.code)
    assert.are.equal('out\n', result.stdout)
    assert.are.equal('err\n', result.stderr)
  end)

  it('fails, not raises, on a command that is not there', function()
    local result = system.sync({ dir .. '/no-such-command' })
    assert.are.equal(127, result.code)
    assert.is_truthy(result.stderr:find('no-such-command', 1, true))
  end)

  it('hands back a result when its children outlive the deadline', function()
    -- The child holds the output open past the kill: `:wait()` alone gives nil
    h.write(dir .. '/slow', { '#!/bin/sh', 'sleep 5', 'echo late' })
    vim.fn.setfperm(dir .. '/slow', 'rwxr-xr-x')
    local start = vim.uv.hrtime()
    local result = system.sync({ dir .. '/slow' }, { timeout = 200 })
    local took = (vim.uv.hrtime() - start) / 1e6
    assert.are.equal(system.TIMED_OUT, result.code)
    assert.is_truthy(result.stderr:find('timed out', 1, true))
    assert.is_true(took < 2000, ('took %d ms'):format(took))
  end)

  it(
    'kills what a detached command started once it runs out of time',
    function()
      local marker = dir .. '/still-running'
      h.write(dir .. '/spawner', {
        '#!/bin/sh',
        '(sleep 1; touch "' .. marker .. '") &',
        'sleep 5',
      })
      vim.fn.setfperm(dir .. '/spawner', 'rwxr-xr-x')
      local result = system.sync(
        { dir .. '/spawner' },
        { timeout = 200, detach = true }
      )
      assert.are.equal(system.TIMED_OUT, result.code)
      vim.wait(1500)
      assert.are.equal(0, vim.fn.filereadable(marker))
    end
  )
end)
