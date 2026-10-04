local h = require('helpers')

describe('util.harper', function()
  local dir, cleanup, restore_stdpath

  before_each(function()
    dir, cleanup = h.tmpdir()
    h.unload('util.harper')
    restore_stdpath = h.stub(
      vim.fn,
      'stdpath',
      function(what) return vim.fs.joinpath(dir, what) end
    )
  end)
  after_each(function()
    restore_stdpath()
    cleanup()
  end)

  it(
    'merges the spell lists and the learned words, sorted and unique',
    function()
      h.write(
        dir .. '/config/spell/en.utf-8.add.txt',
        { 'zebra', ' apple ', '' }
      )
      h.write(dir .. '/config/spell/vi.txt', { 'apple', 'mango' })
      h.write(dir .. '/state/harper/dictionary.txt', { 'learned', 'zebra' })

      local path = require('util.harper').user_dict()
      assert.equals(dir .. '/state/harper/dictionary.txt', path)
      assert.same(
        { 'apple', 'learned', 'mango', 'zebra' },
        vim.fn.readfile(path)
      )
    end
  )

  it('creates the dictionary when nothing exists yet', function()
    local path = require('util.harper').user_dict()
    assert.same({}, vim.fn.readfile(path))
  end)

  it('builds the dictionary only once a session', function()
    local harper = require('util.harper')
    local path = harper.user_dict()
    h.write(dir .. '/config/spell/late.txt', { 'late' })
    assert.equals(path, harper.user_dict())
    assert.same({}, vim.fn.readfile(path))
  end)
end)
