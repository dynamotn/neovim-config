local h = require('helpers')

describe('util.pick', function()
  local pick, calls, warnings, restores

  before_each(function()
    calls, warnings = {}, {}
    local plugin = require('util.plugin')
    restores = {
      h.stub(_G, 'Snacks', {
        picker = {
          pick = function(source, opts)
            table.insert(calls, { source = source, opts = opts })
          end,
        },
      }),
      h.stub(package.loaded, 'util.root', {
        get = function(opts)
          return '/root' .. (opts and opts.buf and ('/' .. opts.buf) or '')
        end,
      }),
      h.stub(plugin, 'warn', function(msg) table.insert(warnings, msg) end),
    }
    h.unload('util.pick')
    pick = require('util.pick')
  end)
  after_each(function()
    for i = #restores, 1, -1 do
      restores[i]()
    end
  end)

  it('opens files at the root of the buffer by default', function()
    pick.open()
    assert.are.equal('files', calls[1].source)
    assert.are.equal('/root', calls[1].opts.cwd)
  end)

  it('asks the root of the buffer it is given', function()
    pick.open('files', { buf = 7 })
    assert.are.equal('/root/7', calls[1].opts.cwd)
  end)

  it('keeps the working directory with root = false', function()
    pick.open('files', { root = false })
    assert.is_nil(calls[1].opts.cwd)
  end)

  it('keeps a cwd it is given', function()
    pick.open('grep', { cwd = '/elsewhere' })
    assert.are.equal('/elsewhere', calls[1].opts.cwd)
  end)

  it('turns down a boolean cwd and falls back on the root', function()
    pick.open('files', { cwd = true })
    assert.are.equal('/root', calls[1].opts.cwd)
    assert.are.equal(1, #warnings)
  end)

  it('translates the generic names into Snacks sources', function()
    pick.open('live_grep')
    pick.open('oldfiles')
    pick.open('auto')
    pick.open('buffers')
    assert.are.same(
      { 'grep', 'recent', 'files', 'buffers' },
      vim.tbl_map(function(call) return call.source end, calls)
    )
  end)

  it('hands a key a function, and leaves its options untouched', function()
    local opts = { root = false, hidden = true }
    local open = pick('files', opts)
    open()
    open()
    assert.are.equal(2, #calls)
    assert.are.same({ root = false, hidden = true }, opts)
    assert.is_true(calls[2].opts.hidden)
  end)

  it('opens the files of this configuration', function()
    pick.config_files()()
    assert.are.equal(vim.fn.stdpath('config'), calls[1].opts.cwd)
  end)
end)
