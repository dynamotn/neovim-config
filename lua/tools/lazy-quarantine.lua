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

--- Seconds a commit has to have been in the repository before it may be
--- checked out, the same window the npm, bun, pnpm, uv and Mason sides use
local MIN_RELEASE_AGE = 7 * 24 * 60 * 60

--- The same window, for `:checkhealth util` to hold the others against
---@type integer
M.window = MIN_RELEASE_AGE

--- Run `git` in `dir` and hand back its output, or nil when it fails
---@param dir string
---@param args string[]
---@return string?
local function git(dir, args)
  local command = { 'git', '-C', dir }
  vim.list_extend(command, args)
  local ok, result = pcall(
    function() return vim.system(command, { text = true }):wait(10000) end
  )
  if not ok or result.code ~= 0 then return nil end
  local out = vim.trim(result.stdout or '')
  return out ~= '' and out or nil
end

--- Whether `rev` has been in the repository for longer than the window
---@param dir string
---@param rev string
---@param now integer
---@return boolean
local function aged(dir, rev, now)
  local committed = tonumber(git(dir, { 'log', '-1', '--format=%ct', rev }))
  return committed ~= nil and os.difftime(now, committed) >= MIN_RELEASE_AGE
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
    '--until=' .. os.date('!%Y-%m-%dT%H:%M:%S+00:00', now - MIN_RELEASE_AGE),
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

--- The wrapper `setup` put in place
---@type function?
local wrapper

--- Whether lazy.nvim is still calling that wrapper
---
--- `get_target` is private to lazy.nvim, so a release that renames it would
--- leave the window in place and reaching nothing. `:checkhealth util` asks
--- here rather than assuming the patch held.
---@return boolean
function M.installed()
  local ok, Git = pcall(require, 'lazy.manage.git')
  return ok and wrapper ~= nil and Git.get_target == wrapper
end

--- Put the window in front of lazy.nvim's target resolution
---
--- Called before `require('lazy').setup()`, since that already installs what
--- is missing.
function M.setup()
  local Config = require('lazy.core.config')
  local Git = require('lazy.manage.git')
  local resolve = Git.get_target

  ---@param plugin LazyPlugin
  Git.get_target = function(plugin)
    local target = resolve(plugin)
    return M.target(plugin, target, function()
      -- The same spec `get_target` resolved the release from, so the window
      -- only ever moves to an older release of the range asked for, never
      -- out of it.
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
    end)
  end
  wrapper = Git.get_target
end

return M
