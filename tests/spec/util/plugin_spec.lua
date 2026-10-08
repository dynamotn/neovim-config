local h = require('helpers')

describe('util.plugin', function()
  local plugin
  before_each(function()
    h.unload('util.plugin')
    plugin = require('util.plugin')
  end)

  it('drops repeated items and keeps the first order', function()
    assert.are.same(
      { 'b', 'a', 'c' },
      plugin.dedup({ 'b', 'a', 'b', 'c', 'a' })
    )
    assert.are.same({}, plugin.dedup({}))
  end)

  it('extends a nested list, creating the tables on the way', function()
    local t = { servers = { vtsls = { filetypes = { 'ts' } } } }
    plugin.extend(t, 'servers.vtsls.filetypes', { 'vue' })
    assert.are.same({ 'ts', 'vue' }, t.servers.vtsls.filetypes)
    plugin.extend(t, 'a.b', { 1, 2 })
    assert.are.same({ 1, 2 }, t.a.b)
  end)

  it('registers the LazyFile event with lazy.nvim', function()
    plugin.lazy_file()
    local mappings = require('lazy.core.handler.event').mappings
    assert.are.same(plugin.lazy_file_events, mappings.LazyFile.event)
    assert.are.equal(mappings.LazyFile, mappings['User LazyFile'])
  end)

  describe('set_default', function()
    local bufnr
    before_each(function()
      bufnr = h.buffer()
      vim.api.nvim_set_current_buf(bufnr)
      plugin.snapshot_options()
    end)
    after_each(function() vim.cmd('silent! %bwipeout!') end)

    it('sets an option still at its global value', function()
      assert.is_true(plugin.set_default('foldmethod', 'expr'))
      assert.are.equal('expr', vim.wo.foldmethod)
    end)

    it('sets an option it set itself before', function()
      plugin.set_default('foldmethod', 'expr')
      assert.is_true(plugin.set_default('foldmethod', 'marker'))
    end)

    it('leaves an option something else changed', function()
      vim.wo.foldmethod = 'syntax'
      assert.is_false(plugin.set_default('foldmethod', 'expr'))
      assert.are.equal('syntax', vim.wo.foldmethod)
    end)
  end)
end)
