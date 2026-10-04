local h = require('helpers')

describe('tools.completion.cached', function()
  local cached, inner, calls, respond

  before_each(function()
    calls = 0
    respond = nil
    inner = {}
    package.loaded['spec.fake_source'] = {
      new = function(opts, config)
        inner.opts, inner.config = opts, config
        return setmetatable(inner, {
          __index = {
            get_completions = function(_, _, callback)
              calls = calls + 1
              respond = callback
            end,
          },
        })
      end,
    }
    h.unload('tools.completion.cached')
    cached = require('tools.completion.cached')
  end)
  after_each(function() package.loaded['spec.fake_source'] = nil end)

  ---@param items string[]
  local function answer(items)
    respond({
      items = vim.tbl_map(function(label) return { label = label } end, items),
    })
  end

  it('wraps the source it is pointed at', function()
    local source = cached.new(
      { source = 'spec.fake_source', opts = { a = 1 } },
      { id = 'x' }
    )
    assert.are.same({ a = 1 }, inner.opts)
    assert.are.same({ id = 'x' }, inner.config)
    assert.are.equal(10000, source.ttl)
    assert.are.equal(
      5,
      cached.new({ source = 'spec.fake_source', ttl = 5 }, {}).ttl
    )
  end)

  it('asks the wrapped source whether it is enabled', function()
    local source = cached.new({ source = 'spec.fake_source' }, {})
    assert.is_true(source:enabled())
    inner.enabled = function() return false end
    assert.is_false(source:enabled())
  end)

  it('passes on trigger characters, or none', function()
    local source = cached.new({ source = 'spec.fake_source' }, {})
    assert.are.same({}, source:get_trigger_characters())
    inner.get_trigger_characters = function() return { '.' } end
    assert.are.same({ '.' }, source:get_trigger_characters())
  end)

  it('waits for the first capture and answers complete', function()
    local source = cached.new({ source = 'spec.fake_source' }, {})
    local response
    source:get_completions({}, function(r) response = r end)
    assert.is_nil(response)
    answer({ 'alpha' })
    assert.are.same({
      items = { { label = 'alpha' } },
      is_incomplete_forward = false,
      is_incomplete_backward = false,
    }, response)
  end)

  it('runs one capture for callers arriving meanwhile', function()
    local source = cached.new({ source = 'spec.fake_source' }, {})
    local answered = 0
    source:get_completions({}, function() answered = answered + 1 end)
    source:get_completions({}, function() answered = answered + 1 end)
    assert.are.equal(1, calls)
    answer({ 'x' })
    assert.are.equal(2, answered)
  end)

  it('treats a missing response as no items', function()
    local source = cached.new({ source = 'spec.fake_source' }, {})
    local response
    source:get_completions({}, function(r) response = r end)
    respond(nil)
    assert.are.same({}, response.items)
  end)

  it('serves fresh items from the cache without asking again', function()
    local source = cached.new({ source = 'spec.fake_source' }, {})
    source:get_completions({}, function() end)
    answer({ 'alpha' })
    local response
    source:get_completions({}, function(r) response = r end)
    assert.are.equal(1, calls)
    assert.are.same({ { label = 'alpha' } }, response.items)
  end)

  it('hands out copies of the cached items', function()
    local source = cached.new({ source = 'spec.fake_source' }, {})
    local first
    source:get_completions({}, function(r) first = r end)
    answer({ 'alpha' })
    first.items[1].score = 99
    local second
    source:get_completions({}, function(r) second = r end)
    assert.is_nil(second.items[1].score)
  end)

  it('captures stale items again on the next CursorHold, once', function()
    local source = cached.new({ source = 'spec.fake_source', ttl = 0 }, {})
    source:get_completions({}, function() end)
    answer({ 'old' })
    source.captured = vim.uv.now() - 10
    source:get_completions({}, function() end)
    source:get_completions({}, function() end)
    assert.is_true(source.pending)
    assert.are.equal(1, calls)
    vim.api.nvim_exec_autocmds('CursorHold', {})
    assert.is_false(source.pending)
    assert.are.equal(2, calls)
    answer({ 'new' })
    local response
    source:get_completions({}, function(r) response = r end)
    assert.are.same({ { label = 'new' } }, response.items)
  end)
end)
