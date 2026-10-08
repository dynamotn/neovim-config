local h = require('helpers')

describe('util.format', function()
  local format, restores

  ---@param name string
  ---@param priority number
  ---@param sources string[]
  ---@param primary? boolean
  local function formatter(name, priority, sources, primary)
    return {
      name = name,
      priority = priority,
      primary = primary,
      sources = function() return sources end,
      format = function() end,
    }
  end

  before_each(function()
    h.unload('util.format')
    format = require('util.format')
    restores = {
      h.stub(vim.g, 'autoformat', nil),
    }
  end)
  after_each(function()
    for i = #restores, 1, -1 do
      restores[i]()
    end
    vim.b.autoformat = nil
  end)

  it('runs only the first primary formatter with sources', function()
    format.register(formatter('lsp', 1, { 'lua_ls' }, true))
    format.register(formatter('conform', 100, { 'stylua' }, true))
    format.register(formatter('extra', 50, { 'x' }))
    format.register(formatter('empty', 200, {}, true))

    local resolved = format.resolve(0)
    local active = {}
    for _, f in ipairs(resolved) do
      active[f.name] = f.active
    end
    assert.are.same(
      { 'empty', 'conform', 'extra', 'lsp' },
      vim.tbl_map(function(f) return f.name end, resolved)
    )
    assert.are.same(
      { empty = false, conform = true, extra = true, lsp = false },
      active
    )
  end)

  it('takes the buffer setting over the global one', function()
    assert.is_true(format.enabled())
    vim.g.autoformat = false
    assert.is_false(format.enabled())
    vim.b.autoformat = true
    assert.is_true(format.enabled())
  end)
end)
