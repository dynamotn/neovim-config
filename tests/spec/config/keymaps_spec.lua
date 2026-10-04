local h = require('helpers')

describe('config.keymaps', function()
  before_each(function()
    vim.g.mapleader = ' '
    dofile(h.root .. '/lua/config/keymaps.lua')
  end)

  local function map(mode, lhs) return vim.fn.maparg(lhs, mode, false, true) end

  it('maps the path copiers', function()
    for _, suffix in ipairs({
      'y',
      'Y',
      'l',
      'L',
      'c',
      'C',
      'd',
      'D',
      'P',
      'n',
      'N',
    }) do
      local m = map('n', ' fy' .. suffix)
      assert.is_not_nil(m.callback, suffix)
    end
  end)

  it('maps the tab jumps', function()
    for number = 1, 9 do
      assert.are.equal(
        '<cmd>tabn' .. number .. '<cr>',
        map('n', ' <Tab>' .. number).rhs
      )
    end
  end)

  it(
    'pastes over a selection without yanking it',
    function() assert.are.equal('"_dP', map('v', 'p').rhs) end
  )

  describe('smart delete', function()
    local function expand(key, line)
      local bufnr = h.buffer({ lines = { line } })
      vim.api.nvim_set_current_buf(bufnr)
      return map('n', key).callback()
    end

    for _, key in ipairs({ 'd', 'x', 'c', 'C', 'X' }) do
      it(
        key .. ' goes to the black hole on a blank line',
        function() assert.are.equal('"_' .. key, expand(key, '   ')) end
      )
      it(
        key .. ' yanks on a line with text',
        function() assert.are.equal(key, expand(key, 'text')) end
      )
    end
  end)

  describe('command abbreviations', function()
    local function expand(lhs, cmdtype, cmdline)
      local restores = {
        h.stub(vim.fn, 'getcmdtype', function() return cmdtype end),
        h.stub(vim.fn, 'getcmdline', function() return cmdline end),
      }
      local abbr = vim.fn.maparg(lhs, 'c', true, true)
      local result = abbr.callback()
      for _, restore in ipairs(restores) do
        restore()
      end
      return result
    end

    it('expands a whole command', function()
      assert.are.equal('w', expand('W', ':', 'W'))
      assert.are.equal('wq', expand('WQ', ':', 'WQ'))
      assert.are.equal('w ! sudo tee % > /dev/null', expand('ww', ':', 'ww'))
    end)

    it('leaves the word inside a longer command', function()
      assert.are.equal('W', expand('W', ':', 'e foo/W'))
      assert.are.equal('ww', expand('ww', ':', 'e foo/ww'))
    end)

    it(
      'leaves a search alone',
      function() assert.are.equal('ww', expand('ww', '/', 'ww')) end
    )
  end)
end)
