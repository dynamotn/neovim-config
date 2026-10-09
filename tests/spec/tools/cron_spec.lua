local h = require('helpers')

describe('tools.cron', function()
  local cron

  before_each(function()
    h.unload('tools.cron')
    cron = require('tools.cron')
  end)
  after_each(function() vim.cmd('silent! %bwipeout!') end)

  local function utc(...) return cron.utc_time(...) end

  it('counts UTC time from the epoch', function()
    assert.equals(0, utc(1970, 1, 1, 0, 0))
    assert.equals(951868800, utc(2000, 3, 1, 0, 0))
    assert.equals(1791554820, utc(2026, 10, 9, 14, 7))
  end)

  local function describe_expr(expr) return cron.describe(cron.parse(expr)) end

  describe('parse', function()
    it('takes lists, ranges, steps, names and macros', function()
      local s = assert(cron.parse('5/20 9-17/4 * jan,MAR mon-fri'))
      assert.same({ [5] = true, [25] = true, [45] = true }, s.sets[1])
      assert.same({ [9] = true, [13] = true, [17] = true }, s.sets[2])
      assert.same({ [1] = true, [3] = true }, s.sets[4])
      assert.is_true(s.sets[5][1] and s.sets[5][5])
      assert.same({ '0', '0', '*', '*', '*' }, cron.parse('@daily').fields)
      assert.is_true(cron.parse('@reboot').reboot)
      assert.equals(
        'Asia/Ho_Chi_Minh',
        cron.parse('CRON_TZ=Asia/Ho_Chi_Minh 0 9 * * *').tz
      )
    end)

    it(
      'takes 7 for Sunday',
      function() assert.same({ [0] = true }, cron.parse('0 0 * * 7').sets[5]) end
    )

    it('says why a schedule is none', function()
      local function err(expr) return select(2, cron.parse(expr)) end
      assert.equals('4 fields where cron takes five', err('* * * *'))
      assert.equals('`60` is outside the minute range 0-59', err('60 * * * *'))
      assert.equals('`foo` is no month', err('0 0 1 foo *'))
      assert.equals('`@often` is no macro', err('@often'))
      assert.equals('a step of 0 in `*/0`', err('*/0 * * * *'))
    end)
  end)

  describe('describe', function()
    it('reads a schedule out', function()
      assert.equals('every minute', describe_expr('* * * * *'))
      assert.equals('every 5 minutes', describe_expr('*/5 * * * *'))
      assert.equals('at 03:00', describe_expr('0 3 * * *'))
      assert.equals(
        'at 09:30, 18:30 on Mon–Fri',
        describe_expr('30 9,18 * * 1-5')
      )
      assert.equals('at minute 15 of every hour', describe_expr('15 * * * *'))
      assert.equals(
        'every 15 minutes, hours 9–17 on Mon–Fri',
        describe_expr('*/15 9-17 * * mon-fri')
      )
      assert.equals(
        'at 00:00 on day 1 of the month in Jan',
        describe_expr('@yearly')
      )
      assert.equals(
        'at 00:00 on day 13 of the month or on Fri',
        describe_expr('0 0 13 * 5')
      )
      assert.equals('at boot', describe_expr('@reboot'))
    end)
  end)

  describe('next_runs', function()
    it('finds the next times, in UTC', function()
      local from = utc(2026, 10, 9, 14, 7) -- a Friday
      assert.same(
        { utc(2026, 10, 9, 14, 10), utc(2026, 10, 9, 14, 15) },
        cron.next_runs(cron.parse('*/5 * * * *'), from, 2, true)
      )
      assert.same(
        { utc(2026, 10, 12, 9, 0) },
        cron.next_runs(cron.parse('0 9 * * 1'), from, 1, true)
      )
      assert.same(
        { utc(2028, 2, 29, 0, 0) },
        cron.next_runs(cron.parse('0 0 29 2 *'), from, 1, true)
      )
    end)

    it('takes either day when both are given', function()
      local from = utc(2026, 10, 9, 14, 7)
      -- the 13th is a Tuesday; the Friday is the 16th
      assert.same(
        { utc(2026, 10, 13, 0, 0), utc(2026, 10, 16, 0, 0) },
        cron.next_runs(cron.parse('0 0 13 * 5'), from, 2, true)
      )
    end)

    it(
      'finds nothing for a date that never comes',
      function()
        assert.same({}, cron.next_runs(cron.parse('0 0 30 2 *'), 0, 1, true))
      end
    )
  end)

  describe('find', function()
    it('reads a crontab, its variables and its time zone', function()
      local entries = cron.find({
        '# m h dom mon dow command',
        'MAILTO=me',
        '*/5 * * * * /usr/bin/backup --now',
        'CRON_TZ=UTC',
        '@daily /usr/bin/rotate',
      }, 'crontab')
      assert.same({
        { row = 2, expr = '*/5 * * * *', zone = 'local' },
        { row = 4, expr = '@daily', zone = 'UTC' },
      }, entries)
    end)

    it('reads a CronJob, with the time zone of its document', function()
      local lines = {
        'apiVersion: batch/v1',
        'kind: CronJob',
        'spec:',
        '  timeZone: "Europe/Paris"',
        '  schedule: "0 3 * * *" # nightly',
        '---',
        'kind: CronJob',
        'spec:',
        "  schedule: '*/10 * * * *'",
      }
      assert.same({
        { row = 4, expr = '0 3 * * *', zone = 'Europe/Paris' },
        { row = 8, expr = '*/10 * * * *', zone = 'UTC' },
      }, cron.find(lines, 'yaml'))
      assert.same(
        {},
        cron.find({ 'schedule: "0 3 * * *"' }, 'yaml'),
        'a schedule outside a CronJob is not cron'
      )
    end)

    it(
      'reads the schedules of a workflow, in UTC',
      function()
        assert.same(
          {
            { row = 2, expr = '0 3 * * 1', zone = 'UTC', github = true },
          },
          cron.find({
            'on:',
            '  schedule:',
            "    - cron: '0 3 * * 1'",
          }, 'yaml.gh-action')
        )
      end
    )
  end)

  describe('explain', function()
    it('says what is wrong with a schedule', function()
      local _, problems =
        cron.explain({ row = 0, expr = '61 * * * *', zone = 'UTC' }, 0)
      assert.equals(
        'Not a cron schedule: `61` is outside the minute range 0-59',
        problems[1].message
      )
      _, problems = cron.explain(
        { row = 0, expr = '* * * * *', zone = 'UTC', github = true },
        0
      )
      assert.equals(
        'GitHub runs a schedule at most every 5 minutes',
        problems[1].message
      )
      _, problems = cron.explain(
        { row = 0, expr = '@daily', zone = 'UTC', github = true },
        0
      )
      assert.equals(
        'GitHub Actions takes five fields, not a macro',
        problems[1].message
      )
    end)

    it(
      'gives no next run for a zone it cannot work out',
      function()
        assert.equals(
          'at 03:00 (Europe/Paris)',
          cron.explain(
            { row = 0, expr = '0 3 * * *', zone = 'Europe/Paris' },
            0
          )
        )
      end
    )

    it('lists the next runs', function()
      local text = cron.explain(
        { row = 0, expr = '0 3 * * *', zone = 'UTC' },
        utc(2026, 10, 9, 14, 7)
      )
      assert.equals(
        'at 03:00 · next Sat 10 Oct 03:00, Sun 11 Oct 03:00, Mon 12 Oct 03:00 UTC',
        text
      )
    end)
  end)

  it('puts the schedule at the end of its line, once per buffer', function()
    local bufnr = h.buffer({
      lines = { '0 3 * * * /bin/true', '61 * * * * /bin/false' },
    })
    vim.bo[bufnr].filetype = 'crontab'
    cron.attach(bufnr)
    cron.attach(bufnr)
    local marks = vim.api.nvim_buf_get_extmarks(
      bufnr,
      cron.NAMESPACE,
      0,
      -1,
      { details = true }
    )
    assert.equals(1, #marks)
    assert.equals(0, marks[1][2])
    assert.is_truthy(marks[1][4].virt_text[1][1]:find('^⏱ at 03:00 · next'))
    local diagnostics =
      vim.diagnostic.get(bufnr, { namespace = cron.DIAGNOSTICS })
    assert.equals(1, #diagnostics)
    assert.equals(1, diagnostics[1].lnum)
    assert.equals(1, #vim.api.nvim_get_autocmds({
      group = 'dy_cron_' .. bufnr,
      event = 'TextChanged',
    }))
  end)
end)
