local h = require('helpers')

describe('util.json_schema', function()
  local json_schema, ns, restore, deferred

  --- A stand-in for the jsonls client, recording what it is sent
  local function fake_client(opts)
    opts = opts or {}
    local client = { id = opts.id or 1, sent = {}, stopped = false }
    function client:is_stopped() return self.stopped end
    function client:notify(method, params)
      table.insert(self.sent, { method = method, params = params })
    end
    return client
  end

  --- Run the deferred callbacks recorded so far, oldest first
  local function flush()
    local queue = deferred
    deferred = {}
    for _, item in ipairs(queue) do
      item.fn()
    end
  end

  local function report(bufnr, messages)
    local diagnostics = {}
    for i, message in ipairs(messages) do
      table.insert(
        diagnostics,
        { lnum = 0, col = i, message = message, severity = 1 }
      )
    end
    vim.diagnostic.set(ns, bufnr, diagnostics)
  end

  local function unreachable(url, reason)
    return ("Unable to load schema from '%s': %s."):format(
      url,
      reason or 'connect ECONNRESET'
    )
  end

  before_each(function()
    h.unload('util.json_schema')
    json_schema = require('util.json_schema')
    ns = vim.api.nvim_create_namespace('test.json_schema')
    deferred = {}
    restore = h.stub(
      vim,
      'defer_fn',
      function(fn, timeout)
        table.insert(deferred, { fn = fn, timeout = timeout })
      end
    )
  end)

  after_each(function() restore() end)

  describe('retry_failed', function()
    it('returns nothing for a buffer without diagnostics', function()
      local client = fake_client()
      assert.are.same({}, json_schema.retry_failed(client, h.buffer()))
      assert.are.same({}, deferred)
    end)

    it('ignores diagnostics about anything else', function()
      local bufnr = h.buffer()
      report(bufnr, { 'Missing property "name".', 'Trailing comma' })
      assert.are.same({}, json_schema.retry_failed(fake_client(), bufnr))
    end)

    it('schedules a fetch of every failed URL after a backoff', function()
      local bufnr = h.buffer()
      local client = fake_client()
      report(bufnr, {
        unreachable('https://a.example/schema.json'),
        unreachable('https://b.example/schema.json'),
      })
      local failed = json_schema.retry_failed(client, bufnr)
      assert.are.same({
        ['https://a.example/schema.json'] = true,
        ['https://b.example/schema.json'] = true,
      }, failed)
      assert.are.equal(2, #deferred)
      assert.are.equal(1000, deferred[1].timeout)
      assert.are.same({}, client.sent)
      flush()
      local urls = vim.tbl_map(function(s) return s.params end, client.sent)
      table.sort(urls)
      assert.are.same(
        { 'https://a.example/schema.json', 'https://b.example/schema.json' },
        urls
      )
      for _, s in ipairs(client.sent) do
        assert.are.equal('json/schemaContent', s.method)
      end
    end)

    it('counts a URL reported twice in one buffer once', function()
      local bufnr = h.buffer()
      report(bufnr, {
        unreachable('https://a.example/s.json'),
        unreachable('https://a.example/s.json'),
      })
      json_schema.retry_failed(fake_client(), bufnr)
      assert.are.equal(1, #deferred)
    end)

    for _, reason in ipairs({
      'Bad request',
      'Unauthorized',
      'Forbidden',
      'Not Found',
      'Method not allowed',
    }) do
      it('gives up on a URL that failed with ' .. reason, function()
        local bufnr = h.buffer()
        report(bufnr, { unreachable('https://a.example/s.json', reason) })
        assert.are.same({}, json_schema.retry_failed(fake_client(), bufnr))
        assert.are.same({}, deferred)
      end)
    end

    it('does not schedule a URL whose attempt is still pending', function()
      local bufnr = h.buffer()
      local client = fake_client()
      report(bufnr, { unreachable('https://a.example/s.json') })
      json_schema.retry_failed(client, bufnr)
      json_schema.retry_failed(client, bufnr)
      assert.are.equal(1, #deferred)
    end)

    it('backs off further on every attempt, and stops after three', function()
      local bufnr = h.buffer()
      local client = fake_client()
      report(bufnr, { unreachable('https://a.example/s.json') })
      local timeouts = {}
      for _ = 1, 5 do
        json_schema.retry_failed(client, bufnr)
        for _, item in ipairs(deferred) do
          table.insert(timeouts, item.timeout)
        end
        flush()
      end
      assert.are.same({ 1000, 3000, 9000 }, timeouts)
      assert.are.equal(3, #client.sent)
    end)

    it('gives a URL its budget back once it stops failing', function()
      local bufnr = h.buffer()
      local client = fake_client()
      report(bufnr, { unreachable('https://a.example/s.json') })
      for _ = 1, 3 do
        json_schema.retry_failed(client, bufnr)
        flush()
      end
      json_schema.retry_failed(client, bufnr)
      assert.are.same({}, deferred)

      report(bufnr, {})
      json_schema.retry_failed(client, bufnr)
      report(bufnr, { unreachable('https://a.example/s.json') })
      json_schema.retry_failed(client, bufnr)
      assert.are.equal(1, #deferred)
      assert.are.equal(1000, deferred[1].timeout)
    end)

    it('does not notify a client stopped before the backoff ran out', function()
      local bufnr = h.buffer()
      local client = fake_client()
      report(bufnr, { unreachable('https://a.example/s.json') })
      json_schema.retry_failed(client, bufnr)
      client.stopped = true
      flush()
      assert.are.same({}, client.sent)
    end)
  end)

  describe('on_init', function()
    local restore_attached, attached

    before_each(function()
      attached = true
      restore_attached = h.stub(
        vim.lsp,
        'buf_is_attached',
        function() return attached end
      )
    end)
    after_each(function() restore_attached() end)

    it('retries when the diagnostics of an attached buffer change', function()
      local client = fake_client()
      json_schema.on_init(client)
      local bufnr = h.buffer()
      report(bufnr, { unreachable('https://a.example/s.json') })
      assert.are.equal(1, #deferred)
    end)

    it('leaves buffers the client is not attached to alone', function()
      attached = false
      json_schema.on_init(fake_client())
      report(h.buffer(), { unreachable('https://a.example/s.json') })
      assert.are.same({}, deferred)
    end)

    it('does nothing once the client is stopped', function()
      local client = fake_client()
      json_schema.on_init(client)
      client.stopped = true
      report(h.buffer(), { unreachable('https://a.example/s.json') })
      assert.are.same({}, deferred)
    end)

    it('replaces the autocmds of a previous client', function()
      local old = fake_client({ id = 1 })
      old.stopped = true
      json_schema.on_init(old)
      json_schema.on_init(fake_client({ id = 2 }))
      local autocmds = vim.api.nvim_get_autocmds({ group = 'util.json_schema' })
      assert.are.equal(2, #autocmds)
      report(h.buffer(), { unreachable('https://a.example/s.json') })
      assert.are.equal(1, #deferred)
    end)

    it('forgets what a deleted buffer reported', function()
      local client = fake_client()
      json_schema.on_init(client)
      local bufnr = h.buffer()
      report(bufnr, { unreachable('https://a.example/s.json') })
      flush()
      vim.api.nvim_buf_delete(bufnr, { force = true })
      -- Budget is not given back by deleting the buffer: one attempt is spent
      local other = h.buffer()
      report(other, { unreachable('https://a.example/s.json') })
      assert.are.equal(1, #deferred)
      assert.are.equal(3000, deferred[1].timeout)
    end)
  end)
end)
