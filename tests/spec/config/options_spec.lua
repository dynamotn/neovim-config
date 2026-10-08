local h = require('helpers')

describe('config.options', function()
  local dir, cleanup, cwd, restores
  before_each(function()
    h.globals()
    dir, cleanup = h.tmpdir()
    cwd = vim.fn.getcwd()
    vim.cmd.cd(dir)
    -- Root detection wants lazy.nvim set up; the working directory is the
    -- root it would find for an unnamed buffer anyway
    restores = {
      h.stub(package.loaded, 'util.root', {
        get = function() return vim.fn.getcwd() end,
      }),
    }
  end)
  after_each(function()
    for _, restore in ipairs(restores) do
      restore()
    end
    vim.cmd.cd(cwd)
    cleanup()
  end)

  local function load() dofile(h.root .. '/lua/config/options.lua') end

  it('sets the editor options', function()
    load()
    assert.are.equal('80,120', vim.o.colorcolumn)
    assert.is_true(vim.o.backup)
    assert.are.equal(vim.fn.stdpath('state') .. '/backup', vim.o.backupdir)
    assert.are.equal(2, vim.o.modelines)
    assert.is_true(vim.o.wrap)
    assert.is_nil(vim.o.mouse:find('a', 1, true))
    assert.are.same(
      { 'en_us', 'vi', 'proper', 'technical' },
      vim.opt.spelllang:get()
    )
  end)

  it('turns off the non-Lua providers', function()
    load()
    for _, provider in ipairs({ 'python3', 'perl', 'ruby', 'node' }) do
      assert.are.equal(0, vim.g['loaded_' .. provider .. '_provider'])
    end
  end)

  it('sets the background from dark_mode', function()
    DyNeo.dark_mode = false
    load()
    assert.are.equal('light', vim.o.background)
    DyNeo.dark_mode = true
    load()
    assert.are.equal('dark', vim.o.background)
  end)

  it('installs the insert mode abbreviations', function()
    load()
    for abbr, text in pairs(require('config.defaults').abbreviations) do
      local out = vim.api.nvim_exec2('iabbrev ' .. abbr, { output = true })
      assert.truthy(out.output:find(text, 1, true), abbr)
    end
  end)
end)
