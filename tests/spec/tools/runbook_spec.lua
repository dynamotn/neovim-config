local h = require('helpers')

describe('tools.runbook', function()
  local runbook

  before_each(function()
    h.unload('tools.runbook')
    runbook = require('tools.runbook')
  end)
  after_each(function() vim.cmd('silent! %bwipeout!') end)

  local doc = {
    '# Restart',
    '',
    '```bash',
    'echo one',
    '```',
    '',
    'Text between.',
    '',
    '  ~~~console',
    '  $ kubectl get pods',
    '  NAME READY',
    '  $ echo two',
    '  ~~~',
    '',
    '````md',
    '```bash',
    'not a block of its own',
    '```',
    '````',
  }

  describe('block_at', function()
    it('finds the block the row is in, fences included', function()
      local block = runbook.block_at(doc, 4)
      assert.same({
        open = 3,
        close = 5,
        lang = 'bash',
        code = { 'echo one' },
        indent = '',
      }, block)
      assert.same(block, runbook.block_at(doc, 3))
      assert.same(block, runbook.block_at(doc, 5))
    end)

    it('finds nothing outside a block', function()
      assert.is_nil(runbook.block_at(doc, 1))
      assert.is_nil(runbook.block_at(doc, 7))
    end)

    it('reads an indented tilde fence', function()
      local block = runbook.block_at(doc, 10)
      assert.equals('console', block.lang)
      assert.equals('  ', block.indent)
      assert.equals(9, block.open)
      assert.equals(13, block.close)
    end)

    it('lets a longer fence hold a shorter one', function()
      local block = runbook.block_at(doc, 17)
      assert.equals('md', block.lang)
      assert.equals(15, block.open)
      assert.equals(19, block.close)
    end)
  end)

  it('lists the blocks it can run', function()
    local blocks = runbook.blocks(doc)
    assert.same(
      { 'bash', 'console' },
      vim.tbl_map(function(b) return b.lang end, blocks)
    )
  end)

  it(
    'runs only the commands of a console block',
    function()
      assert.equals(
        'kubectl get pods\necho two',
        runbook.code_of(runbook.block_at(doc, 10))
      )
    end
  )

  it('asks before what deletes, destroys or reaches for root', function()
    -- The line it found, to show in the question
    assert.equals(
      'sudo systemctl restart x',
      runbook.danger('sudo systemctl restart x')
    )
    assert.is_truthy(runbook.danger('rm -rf ./build'))
    assert.is_truthy(runbook.danger('kubectl delete pod web-0'))
    assert.is_truthy(runbook.danger('tofu destroy -auto-approve'))
    assert.is_truthy(runbook.danger('git push origin main --force'))
    assert.is_truthy(runbook.danger('psql -c "drop table users"'))
    assert.is_nil(runbook.danger('kubectl get pods'))
    assert.is_nil(runbook.danger('echo pseudo; firmware'))
    -- Flags before the verb, other spellings, other cases
    for _, code in ipairs({
      'kubectl -n prod delete pod web-0',
      'kubectl --context prod delete ns app',
      'rm --recursive --force /srv/data',
      'helm -n app uninstall web',
      'terraform -chdir=infra destroy -auto-approve',
      'terraform apply -destroy',
      'git push origin +main',
      'psql -c "DELETE FROM users"',
      'TRUNCATE users;',
      'find /var/data -delete',
      'kubectl scale deploy/web --replicas=0',
      'echo ok\nsudo reboot',
    }) do
      assert.is_truthy(runbook.danger(code), code)
    end
    assert.is_nil(runbook.danger('kubectl scale deploy/web --replicas=10'))
    assert.is_nil(runbook.danger('git push origin main'))
  end)

  describe('output', function()
    it('fences the output, longer than any fence inside it', function()
      assert.same(
        { '', '  ```output', '  a', '', '  b', '  ```' },
        runbook.fence({ 'a', '', 'b' }, '  ')
      )
      assert.same(
        { '', '````output', '```', '````' },
        runbook.fence({ '```' }, '')
      )
    end)

    it('shows both streams, and how a run ended', function()
      assert.same(
        { 'out', 'err', '[exit 2]' },
        runbook.render({
          code = 2,
          signal = 0,
          stdout = 'out\n',
          stderr = 'err\n',
        })
      )
      assert.same(
        { '[no output]' },
        runbook.render({ code = 0, signal = 0, stdout = '', stderr = '' })
      )
      assert.same(
        { '[stopped: signal 15]' },
        runbook.render({ code = 143, signal = 15, stdout = '', stderr = '' })
      )
    end)

    it('finds the output fence of a block', function()
      local lines =
        { '```sh', 'ls', '```', '', '```output', 'a', '```', 'after' }
      assert.same({ 4, 7 }, { runbook.output_after(lines, 3) })
      assert.is_nil(runbook.output_after({ '```sh', 'ls', '```', 'text' }, 3))
    end)
  end)

  describe('running', function()
    local dir, cleanup

    before_each(function()
      dir, cleanup = h.tmpdir()
    end)
    after_each(function() cleanup() end)

    --- A Markdown buffer in `dir` holding `lines`, made current
    local function buffer(lines)
      local bufnr = h.buffer({ name = dir .. '/runbook.md', lines = lines })
      vim.api.nvim_set_current_buf(bufnr)
      -- Agreed to already, as `allowed` asks the first time
      vim.b[bufnr].dy_runbook_allowed = true
      return bufnr
    end

    --- Run `fn` and wait until `done` says the runs it started are over
    local function settle(done)
      assert.is_true(vim.wait(10000, done, 20), 'the run never finished')
    end

    it(
      'puts the output under the block, and replaces it on the next run',
      function()
        local bufnr =
          buffer({ '```bash', 'pwd', 'echo "$((1 + 1))"', '```', 'after' })
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        runbook.run()
        settle(function() return vim.api.nvim_buf_line_count(bufnr) > 5 end)
        assert.same({
          '```bash',
          'pwd',
          'echo "$((1 + 1))"',
          '```',
          '',
          '```output',
          dir,
          '2',
          '```',
          'after',
        }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))

        vim.api.nvim_buf_set_lines(bufnr, 2, 3, false, { 'echo three' })
        vim.api.nvim_win_set_cursor(0, { 3, 0 })
        runbook.run()
        settle(
          function()
            return vim.api.nvim_buf_get_lines(bufnr, 7, 8, false)[1] == 'three'
          end
        )
        assert.equals(10, vim.api.nvim_buf_line_count(bufnr))
      end
    )

    it('runs every block in turn, and stops at the first that fails', function()
      local bufnr = buffer({
        '```sh',
        'echo first',
        '```',
        '```sh',
        'exit 3',
        '```',
        '```sh',
        'echo never',
        '```',
      })
      local notes = {}
      local restore = h.stub(
        vim,
        'notify',
        function(msg) table.insert(notes, msg) end
      )
      local restore_confirm = h.stub(vim.fn, 'confirm', function() return 1 end)
      runbook.run_all()
      settle(function() return #notes > 0 end)
      restore_confirm()
      restore()
      local text =
        table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')
      assert.is_truthy(text:find('first', 1, true))
      assert.is_truthy(text:find('[exit 3]', 1, true))
      assert.is_falsy(text:find('```output\nnever', 1, true))
      assert.equals('Stopped at block 2, on line 8', notes[1])

      runbook.clear()
      assert.same({
        '```sh',
        'echo first',
        '```',
        '```sh',
        'exit 3',
        '```',
        '```sh',
        'echo never',
        '```',
      }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    end)

    it('runs nothing dangerous unless told to', function()
      local bufnr = buffer({ '```sh', 'sudo true', '```' })
      local restore = h.stub(vim.fn, 'confirm', function() return 2 end)
      local finished
      runbook.run_block(
        bufnr,
        runbook.block_at(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), 2),
        function(ok) finished = ok end
      )
      restore()
      assert.is_false(finished)
      assert.equals(3, vim.api.nvim_buf_line_count(bufnr))
    end)

    it('asks once before running the blocks of a file', function()
      local bufnr = buffer({ '```sh', 'echo hi', '```' })
      vim.b[bufnr].dy_runbook_allowed = nil
      local asked = 0
      local restore = h.stub(vim.fn, 'confirm', function()
        asked = asked + 1
        return 2
      end)
      local finished
      runbook.run_block(
        bufnr,
        runbook.block_at(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), 2),
        function(ok) finished = ok end
      )
      restore()
      assert.equals(1, asked)
      assert.is_false(finished)
      assert.equals(3, vim.api.nvim_buf_line_count(bufnr))
    end)

    it('runs nothing of a buffer that is no file', function()
      local bufnr = h.buffer({ lines = { '```sh', 'echo hi', '```' } })
      vim.bo[bufnr].buftype = 'nofile'
      assert.is_false(runbook.allowed(bufnr))
    end)

    it('stops what a block started, not only its shell', function()
      local bufnr = buffer({ '```sh', 'sleep 30 &', 'sleep 30', '```' })
      local finished
      runbook.run_block(
        bufnr,
        runbook.block_at(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), 2),
        function(ok) finished = ok end
      )
      vim.wait(200)
      runbook.stop()
      settle(function() return finished ~= nil end)
      assert.is_false(finished)
    end)

    it('does not take a line opening with inline code for a fence', function()
      local lines = { '```js``` is inline', 'text', '```sh', 'ls', '```' }
      assert.equals('sh', runbook.block_at(lines, 4).lang)
    end)

    it('sets its mappings on a buffer', function()
      local bufnr = buffer({})
      runbook.attach(bufnr)
      local lhs = vim.tbl_map(
        function(map) return map.desc end,
        vim.api.nvim_buf_get_keymap(bufnr, 'n')
      )
      assert.is_true(vim.tbl_contains(lhs, 'Run Block (Runbook)'))
    end)
  end)
end)
