--- A quarantine window in front of lazy.nvim's plugin updates
---
--- A plugin is as much of a supply chain as a package from npm or PyPI, and a
--- bigger one: whatever it has in it runs in this editor the next time Neovim
--- starts. The rest of these dotfiles hold a freshly published package back
--- for a week before it may be installed -- `min-release-age` in `~/.npmrc`,
--- `minimumReleaseAge` for bun and pnpm, `exclude-newer` in `uv.toml`, and
--- `tools.mason-quarantine` in front of Mason -- so that a compromised
--- release has time to be caught and pulled. lazy.nvim has no setting for it.
---
--- Every decision of what to check out -- `:Lazy update`, the hourly checker,
--- the update the UI offers -- goes through one function, `get_target`, so
--- that is where the window goes: `setup()` wraps it and hands back the
--- newest commit, or the newest release, that has been out long enough. What
--- lazy.nvim does with the target is untouched, so `:Lazy restore` still puts
--- the lockfile back commit for commit, and a pinned plugin stays where it is.
---
--- Nothing is held back that cannot be: a plugin whose history is younger
--- than the window -- a repository published this week -- is installed as
--- lazy.nvim resolved it, since the alternative is not installing it at all.
local M = {}

--- The wait when `DyNeo.quarantine_window` says nothing, the same week the npm,
--- bun, pnpm and uv configurations give the rest of these dotfiles
local DEFAULT_WINDOW = 7 * 24 * 60 * 60

--- The window every side of the quarantine is held to
---
--- Read on each question rather than kept, so `per_machine` has the say it
--- has over every other global -- and so `:checkhealth dyneo` reports what is
--- in force rather than what was in force when this module first loaded.
---@return integer
function M.window()
  local configured = (rawget(_G, 'DyNeo') or {}).quarantine_window
  return type(configured) == 'number' and configured or DEFAULT_WINDOW
end

--- Run `git` in `dir` and hand back its output, or nil when it fails
---
--- A command that succeeds without saying anything -- `checkout` -- hands
--- back nil as well, which is what the second return value is for.
---@param dir string
---@param args string[]
---@return string? output
---@return boolean ran Whether git exited 0
local function git(dir, args)
  local command = { 'git', '-C', dir }
  vim.list_extend(command, args)
  local ok, result = pcall(
    function() return vim.system(command, { text = true }):wait(10000) end
  )
  if not ok or result.code ~= 0 then return nil, false end
  local out = vim.trim(result.stdout or '')
  return out ~= '' and out or nil, true
end

--- When `rev` was committed, in seconds since the epoch
---@param dir string
---@param rev string
---@return integer?
local function committed_at(dir, rev)
  -- Parenthesised: `git` hands back two values, and `tonumber` reads the
  -- second as a base.
  return tonumber((git(dir, { 'log', '-1', '--format=%ct', rev })))
end

--- Whether `rev` has been in the repository for longer than the window
---@param dir string
---@param rev string
---@param now integer
---@return boolean
local function aged(dir, rev, now)
  local committed = committed_at(dir, rev)
  return committed ~= nil and os.difftime(now, committed) >= M.window()
end

--- The newest ancestor of `rev` that is out of quarantine
---
--- `--until` goes by commit date, which is what the window is about: a commit
--- rewritten or merged today is new to this machine whenever it was written.
---@param dir string
---@param rev string
---@param now integer
---@return string?
local function aged_ancestor(dir, rev, now)
  return git(dir, {
    'log',
    '-1',
    -- The main line only: a branch merged today has commits of last week,
    -- and none of them was ever checked out upstream on its own
    '--first-parent',
    '--until=' .. os.date('!%Y-%m-%dT%H:%M:%S+00:00', now - M.window()),
    '--format=%H',
    rev,
  })
end

--- The target lazy.nvim should check out instead of `target`
---
--- `releases` is only asked for when the target is a release -- the `stable`
--- channel -- and lists the ones matching the plugin's `version`, newest
--- first, as `{ tag = ..., commit = ... }`.
---@param plugin LazyPlugin
---@param target GitInfo?
---@param releases? fun(): { tag: string, commit: string?, version: table? }[]
---@param now? integer Seconds since the epoch, for the specs
---@return GitInfo?
function M.target(plugin, target, releases, now)
  if not target or not target.commit then return target end
  -- A plugin held at a commit, a tag or a pin is already where it was told to
  -- be, and a local one is the user's own working copy.
  if plugin.pin or plugin.commit or plugin.tag then return target end
  if plugin._ and plugin._.is_local then return target end

  now = now or os.time()
  if aged(plugin.dir, target.commit, now) then return target end

  if target.tag then
    for _, release in ipairs(releases and releases() or {}) do
      if release.commit and aged(plugin.dir, release.commit, now) then
        return vim.tbl_extend('force', target, {
          tag = release.tag,
          version = release.version,
          commit = release.commit,
        })
      end
    end
    return target
  end

  local commit = aged_ancestor(plugin.dir, target.commit, now)
  if not commit then return target end
  return vim.tbl_extend('force', target, { commit = commit })
end

--- The releases of `plugin` matching the version its spec asks for, newest
--- first, as `M.target` wants them
---
--- The same spec `get_target` resolved the release from, so the window only
--- ever moves to an older release of the range asked for, never out of it.
---@param plugin LazyPlugin
---@return fun(): { tag: string, commit: string?, version: table? }[]
local function releases_of(plugin)
  return function()
    local Config = require('lazy.core.config')
    local Git = require('lazy.manage.git')
    local spec = (plugin.version == nil and plugin.branch == nil)
        and Config.options.defaults.version
      or plugin.version
    local versions = Git.get_versions(plugin.dir, spec or '*')
    table.sort(versions, function(a, b) return b < a end)
    return vim.tbl_map(
      function(version)
        return {
          tag = version.tag,
          version = version,
          commit = Git.ref(plugin.dir, 'tags/' .. version.tag),
        }
      end,
      versions
    )
  end
end

--- The wrapper `setup` put in place, and lazy.nvim's own resolution under it
---@type function?
local wrapper
---@type function?
local resolve

--- Whether lazy.nvim is still calling that wrapper
---
--- `get_target` is private to lazy.nvim, so a release that renames it would
--- leave the window in place and reaching nothing. `:checkhealth dyneo` asks
--- here rather than assuming the patch held.
---@return boolean
function M.installed()
  local ok, Git = pcall(require, 'lazy.manage.git')
  return ok and wrapper ~= nil and Git.get_target == wrapper
end

--- Hold a freshly cloned lazy.nvim back to the window as well
---
--- The bootstrap in `config.lazy` clones lazy.nvim itself and would take
--- whatever was released that morning: the one checkout the window cannot
--- reach the usual way, since lazy.nvim has to be on the runtimepath before
--- it can hold anything back. Once the clone is there it is an ordinary git
--- repository, so the same walk applies -- detached at the newest commit that
--- has been out long enough, which lazy.nvim then manages from.
---@param dir string Where lazy.nvim was cloned
---@param now? integer Seconds since the epoch, for the specs
---@return string? commit The commit checked out, or nil when it stayed put
function M.bootstrap(dir, now)
  local head = git(dir, { 'rev-parse', 'HEAD' })
  if not head then return nil end
  local target = M.target(
    { dir = dir, name = 'lazy.nvim' },
    { commit = head },
    nil,
    now
  )
  if not target or target.commit == head then return nil end
  local _, ran = git(dir, { 'checkout', '--quiet', '--detach', target.commit })
  return ran and target.commit or nil
end

--- The plugins the window is holding back right now
---
--- Asked of lazy.nvim's own resolution and of the window side by side, so a
--- row is only there when the two disagree. A `git log` per plugin, which is
--- why this is a command and not something the statusline could call.
---@param now? integer Seconds since the epoch, for the specs
---@return { name: string, held: string, available: string, clears: integer }[]
function M.held(now)
  now = now or os.time()
  if not resolve then return {} end
  local ok_config, Config = pcall(require, 'lazy.core.config')
  if not ok_config then return {} end

  local rows = {}
  for name, plugin in pairs(Config.plugins or {}) do
    local state = plugin._ or {}
    if state.installed and not state.is_local then
      local ok, target = pcall(resolve, plugin)
      if ok and target and target.commit then
        local held = M.target(plugin, target, releases_of(plugin), now)
        if held and held.commit ~= target.commit then
          local committed = committed_at(plugin.dir, target.commit) or now
          table.insert(rows, {
            name = name,
            held = held.tag or held.commit:sub(1, 7),
            available = target.tag or target.commit:sub(1, 7),
            clears = math.max(
              0,
              math.floor(committed + M.window() - now + 0.5)
            ),
          })
        end
      end
    end
  end
  table.sort(rows, function(a, b) return a.name < b.name end)
  return rows
end

---@class DyPendingUpdate
---@field name string
---@field dir string
---@field from string The commit checked out
---@field to string The commit lazy.nvim would update to
---@field held boolean Whether the quarantine is holding it back
---@field clears integer Seconds until it no longer is

--- Every plugin whose checkout is behind what lazy.nvim would update it to
---
--- Held back or not: a commit out of quarantine lands on the next `:Lazy
--- update` as unread as one still in it, so `:LazyQuarantine review` reads
--- both. `to` is lazy.nvim's own target, not the window's -- the review is
--- of everything on its way, before the window lets it through.
---@param now? integer Seconds since the epoch, for the specs
---@return DyPendingUpdate[]
function M.pending(now)
  now = now or os.time()
  if not resolve then return {} end
  local ok_config, Config = pcall(require, 'lazy.core.config')
  if not ok_config then return {} end

  ---@type DyPendingUpdate[]
  local rows = {}
  for name, plugin in pairs(Config.plugins or {}) do
    local state = plugin._ or {}
    if state.installed and not state.is_local then
      local ok, target = pcall(resolve, plugin)
      local head = ok
        and target
        and target.commit
        and git(plugin.dir, { 'rev-parse', 'HEAD' })
      if head and head ~= target.commit then
        local held = M.target(plugin, target, releases_of(plugin), now)
        local committed = committed_at(plugin.dir, target.commit) or now
        table.insert(rows, {
          name = name,
          dir = plugin.dir,
          from = head,
          to = target.commit,
          held = held ~= nil and held.commit ~= target.commit,
          clears = math.max(0, math.floor(committed + M.window() - now + 0.5)),
        })
      end
    end
  end
  table.sort(rows, function(a, b) return a.name < b.name end)
  return rows
end

--- What `:LazyQuarantine` completes its first argument with
local SUBCOMMANDS = { 'review' }

--- What `:LazyQuarantine` completes the word being typed with
---@param line string The command line so far
---@return string[]
local function complete(_, line)
  local words = vim.split(line, '%s+', { trimempty = true })
  -- The word being typed counts once something of it is there
  local done = #words - (line:sub(-1) == ' ' and 0 or 1)
  if done <= 1 then return SUBCOMMANDS end
  if words[2] == 'review' and done == 2 then
    local ok, Config = pcall(require, 'lazy.core.config')
    local names = ok and vim.tbl_keys(Config.plugins or {}) or {}
    table.sort(names)
    return names
  end
  return {}
end

--- `:LazyQuarantine`, and `:LazyQuarantine review [{plugin}]`
---
--- The window is otherwise invisible: `:Lazy` shows a plugin as up to date
--- when it is a week behind on purpose, and nothing says which plugins those
--- are or how long is left. `review` reads what the updates on their way
--- would bring in, see `tools.plugin-review`.
function M.command()
  vim.api.nvim_create_user_command('LazyQuarantine', function(args)
    if args.fargs[1] == 'review' then
      return require('tools.plugin-review').show(
        M.pending(),
        M.window(),
        args.fargs[2]
      )
    elseif args.fargs[1] then
      return vim.notify(
        'Unknown subcommand: ' .. args.fargs[1],
        vim.log.levels.ERROR,
        { title = 'Quarantine' }
      )
    end
    local rows = M.held()
    if #rows == 0 then
      return vim.notify(
        'Nothing is being held back',
        vim.log.levels.INFO,
        { title = 'Quarantine' }
      )
    end
    local lines = vim.tbl_map(function(row)
      local hours = math.ceil(row.clears / 3600)
      local left = hours > 24 and ('%d days'):format(math.ceil(hours / 24))
        or ('%d hours'):format(hours)
      return ('- %s: on %s, %s waits %s'):format(
        row.name,
        row.held,
        row.available,
        left
      )
    end, rows)
    vim.notify(
      ('Held back for %d days:\n'):format(M.window() / 86400)
        .. table.concat(lines, '\n'),
      vim.log.levels.INFO,
      { title = 'Quarantine' }
    )
  end, {
    nargs = '*',
    complete = complete,
    desc = 'Plugins the release quarantine is holding back, or a review of '
      .. 'what the updates bring',
  })
end

--- Put the window in front of lazy.nvim's target resolution
---
--- Called before `require('lazy').setup()`, since that already installs what
--- is missing.
function M.setup()
  local Git = require('lazy.manage.git')
  resolve = Git.get_target

  ---@param plugin LazyPlugin
  Git.get_target = function(plugin)
    return M.target(plugin, resolve(plugin), releases_of(plugin))
  end
  wrapper = Git.get_target
  M.command()
end

return M
