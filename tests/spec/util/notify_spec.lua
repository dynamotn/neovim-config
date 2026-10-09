local h = require('helpers')

describe('util.notify', function()
  local notify, sent, restore
  before_each(function()
    h.unload('util.notify')
    notify = require('util.notify')
    sent = {}
    restore = h.stub(
      vim,
      'notify',
      function(msg, level, opts)
        table.insert(sent, { msg = msg, level = level, opts = opts })
      end
    )
  end)
  after_each(function() restore() end)

  it('titles a notification after its area, INFO unless told', function()
    local say = notify.titled('Kubernetes')
    say('applied')
    say('failed', vim.log.levels.ERROR, { timeout = 1 })
    assert.same({
      {
        msg = 'applied',
        level = vim.log.levels.INFO,
        opts = { title = 'DyNeo Kubernetes' },
      },
      {
        msg = 'failed',
        level = vim.log.levels.ERROR,
        opts = { title = 'DyNeo Kubernetes', timeout = 1 },
      },
    }, sent)
  end)

  it('is plain DyNeo with no area', function()
    assert.equals('DyNeo', notify.title())
    assert.equals('DyNeo Runbook', notify.title('Runbook'))
  end)
end)
