local h = require('helpers')

describe('config.keymaps', function()
  local restore, restore_keys, claimed
  before_each(function()
    vim.g.mapleader = ' '
    -- The defaults go through Snacks, which is not loaded here: any field or
    -- call on this stand-in hands the stand-in back, so `toggle(...):map()`
    -- chains do nothing. Its `keymap.set` does map a global key, whenever
    -- the right-hand side is one Neovim takes rather than the stand-in.
    local snacks
    snacks = setmetatable({
      keymap = {
        set = function(mode, lhs, rhs, opts)
          opts = vim.deepcopy(opts or {})
          if opts.ft or opts.lsp then return end
          opts.enabled = nil
          if type(rhs) == 'string' or type(rhs) == 'function' then
            vim.keymap.set(mode, lhs, rhs, opts)
          end
        end,
      },
    }, {
      __index = function() return snacks end,
      __call = function() return snacks end,
    })
    restore = h.stub(_G, 'Snacks', snacks)
    -- Keys a plugin spec claims with `keys`, as lazy.nvim's handler sees them
    claimed = {}
    restore_keys = h.stub(require('lazy.core.handler').handlers, 'keys', {
      have = function(_, lhs, mode) return claimed[mode .. lhs] == true end,
    })
  end)
  after_each(function()
    restore_keys()
    restore()
  end)

  -- Specs below run on the mappings as `config.keymaps` leaves them
  before_each(function() dofile(h.root .. '/lua/config/keymaps.lua') end)

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

  it('drops the LSP keys `gr` hides', function()
    for _, lhs in ipairs({ 'grn', 'gra', 'grr', 'gri', 'grt', 'grx' }) do
      assert.are.same({}, map('n', lhs), lhs)
    end
  end)

  describe('smart delete', function()
    local function expand(mode, key, lines)
      local bufnr = h.buffer({ lines = lines })
      vim.api.nvim_set_current_buf(bufnr)
      return map(mode, key).callback()
    end

    for _, case in ipairs({
      { 'n', 'dd' },
      { 'n', 'cc' },
      { 'n', 'x' },
      { 'n', 'X' },
      { 'n', 'C' },
      { 'x', 'd' },
      { 'x', 'x' },
      { 'x', 'c' },
      { 'x', 'C' },
      { 'x', 'X' },
    }) do
      local mode, key = case[1], case[2]
      it(
        mode .. ' ' .. key .. ' goes to the black hole on a blank line',
        function() assert.are.equal('"_' .. key, expand(mode, key, { '   ' })) end
      )
      it(
        mode .. ' ' .. key .. ' yanks on a line with text',
        function() assert.are.equal(key, expand(mode, key, { 'text' })) end
      )
    end

    it('leaves the `d` and `c` operators alone', function()
      -- `d}` on a blank line takes the paragraph after it
      assert.same({}, map('n', 'd'))
      assert.same({}, map('n', 'c'))
    end)

    it('is not mapped in Select mode, where the keys type text', function()
      assert.same({}, map('s', 'd'))
      assert.same({}, map('s', 'x'))
    end)

    -- Typed for real: `v:count1` and `v:register` cannot be stubbed
    local function type_keys(keys, lines)
      vim.api.nvim_set_current_buf(h.buffer({ lines = lines }))
      vim.fn.setreg('"', 'kept')
      vim.api.nvim_feedkeys(keys, 'mx', false)
    end

    it('yanks when the count reaches a line with text', function()
      type_keys('2dd', { '', 'text' })
      assert.are.equal('\ntext\n', vim.fn.getreg('"'))
    end)

    it('keeps the yank when every counted line is blank', function()
      type_keys('2dd', { '', '  ', 'text' })
      assert.are.equal('kept', vim.fn.getreg('"'))
    end)

    it('honours a register given explicitly', function()
      vim.fn.setreg('a', '')
      type_keys('"add', { '' })
      assert.are.equal('\n', vim.fn.getreg('a'))
    end)
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

  it('leaves a key claimed by a plugin spec to it', function()
    for _, key in ipairs({ { 'n', '<C-c>' }, { 'x', '<C-r>' } }) do
      vim.keymap.del(key[1], key[2])
      claimed[key[1] .. key[2]] = true
    end
    dofile(h.root .. '/lua/config/keymaps.lua')
    assert.same({}, map('n', '<C-c>'))
    assert.same({}, map('x', '<C-r>'))
    assert.are.equal('<Esc>/\\%V', map('x', '/').rhs)
  end)

  it('searches the selection literally, without yanking it', function()
    vim.api.nvim_set_current_buf(h.buffer({ lines = { 'a.b/c<d\\', 'x' } }))
    vim.fn.setreg('"', 'kept')
    local keys = vim.keycode('0v$h<C-f><CR>')
    vim.api.nvim_feedkeys(keys, 'mx', false)
    assert.are.equal('\\Va.b\\/c<d\\\\', vim.fn.getreg('/'))
    assert.are.equal('kept', vim.fn.getreg('"'))
  end)

  it('keeps the command line of the search mappings in sight', function()
    for _, lhs in ipairs({ '/', '<C-f>', '<C-r>' }) do
      assert.are.equal(0, map('x', lhs).silent, lhs)
    end
    assert.are.equal(1, map('n', '<C-c>').silent)
  end)
end)
