local h = require('helpers')

describe('util.project_rtp', function()
  local dir, cleanup, cwd, restores
  before_each(function()
    dir, cleanup = h.tmpdir()
    cwd = vim.fn.getcwd()
    vim.cmd.cd(dir)
    restores = {
      -- The working directory is the root for an unnamed buffer anyway
      h.stub(package.loaded, 'util.root', {
        get = function() return vim.fn.getcwd() end,
      }),
    }
    h.unload('util.project_rtp')
  end)
  after_each(function()
    for _, restore in ipairs(restores) do
      restore()
    end
    vim.cmd.cd(cwd)
    cleanup()
  end)

  local function load() require('util.project_rtp').setup() end

  it('re-checks the project folder when the directory changes', function()
    load()
    local autocmds = vim.api.nvim_get_autocmds({
      group = 'dy_project_rtp',
      event = 'DirChanged',
    })
    assert.are.equal(1, #autocmds)
  end)

  it('adds a trusted project .nvim folder to the runtimepath', function()
    vim.fn.mkdir(dir .. '/.nvim', 'p')
    table.insert(restores, h.stub(vim.secure, 'read', function() return '' end))
    load()
    assert.is_true(vim.list_contains(vim.opt.rtp:get(), dir .. '/.nvim'))
    vim.opt.rtp:remove(dir .. '/.nvim')
  end)

  it('leaves an untrusted project .nvim folder out', function()
    vim.fn.mkdir(dir .. '/.nvim', 'p')
    table.insert(
      restores,
      h.stub(vim.secure, 'read', function() return nil end)
    )
    load()
    assert.is_false(vim.list_contains(vim.opt.rtp:get(), dir .. '/.nvim'))
  end)
  it('hands lazy.nvim a trusted folder to start with', function()
    vim.fn.mkdir(dir .. '/.nvim', 'p')
    table.insert(restores, h.stub(vim.secure, 'read', function() return '' end))
    assert.are.equal(
      dir .. '/.nvim',
      require('util.project_rtp').startup_path()
    )
    vim.opt.rtp:remove(dir .. '/.nvim')
  end)

  it(
    'hands lazy.nvim nothing without a trusted folder',
    function() assert.is_nil(require('util.project_rtp').startup_path()) end
  )
end)
