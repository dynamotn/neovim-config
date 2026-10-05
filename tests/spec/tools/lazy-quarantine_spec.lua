local h = require('helpers')

local DAY = 24 * 60 * 60
local now = os.time()

--- Run git in `dir`, failing the spec when it does
---@param dir string
---@param args string[]
---@param env? table<string, string>
---@return string
local function git(dir, args, env)
  local command = { 'git', '-C', dir }
  vim.list_extend(command, args)
  local result = vim
    .system(command, {
      text = true,
      env = vim.tbl_extend('force', {
        GIT_AUTHOR_NAME = 'Spec',
        GIT_AUTHOR_EMAIL = 'spec@example.com',
        GIT_COMMITTER_NAME = 'Spec',
        GIT_COMMITTER_EMAIL = 'spec@example.com',
      }, env or {}),
    })
    :wait(10000)
  assert.are.equal(
    0,
    result.code,
    table.concat(command, ' ') .. ': ' .. (result.stderr or '')
  )
  return vim.trim(result.stdout or '')
end

--- A repository whose commits were made `ages` seconds ago, oldest first
---@param ages integer[]
---@return string dir
---@return string[] commits In the order of `ages`
---@return fun() cleanup
local function repository(ages)
  local dir, cleanup = h.tmpdir()
  git(dir, { 'init', '--initial-branch=main', '--quiet' })
  local commits = {}
  for index, age in ipairs(ages) do
    local when = os.date('!%Y-%m-%dT%H:%M:%S+00:00', now - age)
    h.write(vim.fs.joinpath(dir, 'init.lua'), { '-- commit ' .. index })
    git(dir, { 'add', 'init.lua' })
    git(dir, { 'commit', '--quiet', '-m', 'commit ' .. index }, {
      GIT_AUTHOR_DATE = when,
      GIT_COMMITTER_DATE = when,
    })
    commits[index] = git(dir, { 'rev-parse', 'HEAD' })
  end
  return dir, commits, cleanup
end

--- The target the quarantine picks for a branch plugin at `commits[#commits]`
---@param dir string
---@param commit string
---@param plugin? table Fields overriding the plugin
---@param releases? fun(): table[]
---@return table?
local function target(dir, commit, plugin, releases)
  h.unload('tools.lazy-quarantine')
  local quarantine = require('tools.lazy-quarantine')
  return quarantine.target(
    vim.tbl_extend('force', { dir = dir, name = 'spec.nvim' }, plugin or {}),
    { branch = 'main', commit = commit },
    releases,
    now
  )
end

describe('tools.lazy-quarantine', function()
  it('walks back to the newest commit out of quarantine', function()
    local dir, commits, cleanup = repository({ 30 * DAY, 8 * DAY, DAY })
    local picked = target(dir, commits[3])
    cleanup()
    assert.are.equal(commits[2], picked.commit)
    assert.are.equal('main', picked.branch)
  end)

  it('leaves a tip that has been out long enough alone', function()
    local dir, commits, cleanup = repository({ 30 * DAY, 8 * DAY })
    local picked = target(dir, commits[2])
    cleanup()
    assert.are.equal(commits[2], picked.commit)
  end)

  it('installs a repository younger than the window as it is', function()
    local dir, commits, cleanup = repository({ 2 * DAY, DAY })
    local picked = target(dir, commits[2])
    cleanup()
    assert.are.equal(commits[2], picked.commit)
  end)

  it('leaves a plugin held at a commit, a tag or a pin where it is', function()
    local dir, commits, cleanup = repository({ 30 * DAY, DAY })
    local held = {
      { pin = true },
      { commit = commits[2] },
      { tag = 'v1.0.0' },
      { _ = { is_local = true } },
    }
    local picked = vim.tbl_map(
      function(plugin) return target(dir, commits[2], plugin).commit end,
      held
    )
    cleanup()
    assert.are.same({ commits[2], commits[2], commits[2], commits[2] }, picked)
  end)

  it('takes the newest release out of quarantine', function()
    local dir, commits, cleanup = repository({ 30 * DAY, 9 * DAY, DAY })
    local releases = function()
      return {
        { tag = 'v3.0.0', commit = commits[3] },
        { tag = 'v2.0.0', commit = commits[2] },
        { tag = 'v1.0.0', commit = commits[1] },
      }
    end
    h.unload('tools.lazy-quarantine')
    local quarantine = require('tools.lazy-quarantine')
    local picked = quarantine.target(
      { dir = dir, name = 'spec.nvim' },
      { branch = 'main', tag = 'v3.0.0', commit = commits[3] },
      releases,
      now
    )
    cleanup()
    assert.are.equal('v2.0.0', picked.tag)
    assert.are.equal(commits[2], picked.commit)
  end)

  it('keeps the release lazy.nvim picked when none is old enough', function()
    local dir, commits, cleanup = repository({ 2 * DAY, DAY })
    h.unload('tools.lazy-quarantine')
    local quarantine = require('tools.lazy-quarantine')
    local picked = quarantine.target(
      { dir = dir, name = 'spec.nvim' },
      { branch = 'main', tag = 'v2.0.0', commit = commits[2] },
      function() return { { tag = 'v1.0.0', commit = commits[1] } } end,
      now
    )
    cleanup()
    assert.are.equal('v2.0.0', picked.tag)
    assert.are.equal(commits[2], picked.commit)
  end)

  describe('bootstrap', function()
    it('walks a fresh clone back to an aged commit', function()
      local dir, commits, cleanup = repository({ 30 * DAY, 8 * DAY, DAY })
      h.unload('tools.lazy-quarantine')
      local moved = require('tools.lazy-quarantine').bootstrap(dir, now)
      local head = git(dir, { 'rev-parse', 'HEAD' })
      cleanup()
      assert.are.equal(commits[2], moved)
      assert.are.equal(commits[2], head)
    end)

    it('leaves a clone whose tip is old enough', function()
      local dir, commits, cleanup = repository({ 30 * DAY, 8 * DAY })
      h.unload('tools.lazy-quarantine')
      local moved = require('tools.lazy-quarantine').bootstrap(dir, now)
      local head = git(dir, { 'rev-parse', 'HEAD' })
      cleanup()
      assert.is_nil(moved)
      assert.are.equal(commits[2], head)
    end)

    it('copes with a directory that is not a repository', function()
      local dir, cleanup = h.tmpdir()
      h.unload('tools.lazy-quarantine')
      local moved = require('tools.lazy-quarantine').bootstrap(dir, now)
      cleanup()
      assert.is_nil(moved)
    end)
  end)

  describe('held', function()
    local Config, Git, restore_plugins, restore_options, restore_target

    before_each(function()
      Config = require('lazy.core.config')
      Git = require('lazy.manage.git')
      -- `get_target` reads `defaults.version` for a plugin with no version of
      -- its own, and nothing has set lazy.nvim up in a spec.
      restore_options = h.stub(
        Config,
        'options',
        vim.tbl_deep_extend(
          'force',
          Config.options or {},
          { defaults = { version = false } }
        )
      )
      restore_plugins = h.stub(Config, 'plugins', {})
      restore_target = h.stub(Git, 'get_target', Git.get_target)
      h.unload('tools.lazy-quarantine')
      require('tools.lazy-quarantine').setup()
    end)

    after_each(function()
      restore_plugins()
      restore_options()
      restore_target()
      h.unload('tools.lazy-quarantine')
    end)

    it('lists a plugin whose tip is too fresh, and when it clears', function()
      local dir, commits, cleanup = repository({ 30 * DAY, 8 * DAY, 2 * DAY })
      Config.plugins = {
        ['spec.nvim'] = {
          name = 'spec.nvim',
          dir = dir,
          _ = { installed = true },
        },
      }
      local rows = require('tools.lazy-quarantine').held(now)
      cleanup()
      assert.are.equal(1, #rows)
      assert.are.equal('spec.nvim', rows[1].name)
      assert.are.equal(commits[2]:sub(1, 7), rows[1].held)
      assert.are.equal(commits[3]:sub(1, 7), rows[1].available)
      -- Committed two days ago, so five of the seven are left
      assert.are.equal(5, math.floor(rows[1].clears / DAY))
    end)

    it('says nothing about a plugin that is up to date', function()
      local dir, _, cleanup = repository({ 30 * DAY, 8 * DAY })
      Config.plugins = {
        ['spec.nvim'] = {
          name = 'spec.nvim',
          dir = dir,
          _ = { installed = true },
        },
      }
      local rows = require('tools.lazy-quarantine').held(now)
      cleanup()
      assert.are.same({}, rows)
    end)

    it('skips a plugin that is not installed, or is local', function()
      local dir, _, cleanup = repository({ 30 * DAY, DAY })
      Config.plugins = {
        ['gone.nvim'] = { name = 'gone.nvim', dir = dir, _ = {} },
        ['mine.nvim'] = {
          name = 'mine.nvim',
          dir = dir,
          _ = { installed = true, is_local = true },
        },
      }
      local rows = require('tools.lazy-quarantine').held(now)
      cleanup()
      assert.are.same({}, rows)
    end)
  end)

  it('copes with a directory that is not a repository', function()
    local dir, cleanup = h.tmpdir()
    local picked = target(dir, 'deadbeef')
    cleanup()
    assert.are.equal('deadbeef', picked.commit)
  end)
end)
