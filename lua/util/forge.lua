--- The forge a repository lives on, and its API through the forge's own CLI
---
--- GitHub is asked through `gh api` and GitLab through `glab api`: each CLI
--- holds its own token for the host, so none is ever read or passed here.
local M = {}

--- The remotes looked at, in order: the same as Octo and the CI checks use
M.REMOTES = { 'upstream', 'gh', 'github', 'origin' }

--- Milliseconds an API call may take
M.TIMEOUT = 30 * 1000

---@alias DyForgeKind 'github'|'gitlab'

---@class DyForgeRemote
---@field name string The git remote
---@field host string
---@field slug string `owner/repo`, or `group/sub/project`
---@field kind DyForgeKind

--- The host and the path of a clone URL: `https://host/a/b(.git)`,
--- `ssh://git@host:22/a/b`, `git@host:a/b`
---@param url string
---@return string? host
---@return string? slug
function M.parse_url(url)
  local host, path
  local rest = url:match('^%a[%w+.-]*://(.*)$')
  if rest then
    host, path = rest:gsub('^[^@/]*@', ''):match('^([^/]+)/(.-)/?$')
    if host then host = host:gsub(':%d+$', '') end
  else
    host, path = url:match('^[%w_.-]+@([^:]+):(.-)/?$')
  end
  if not host or not path or path == '' then return nil end
  return host:lower(), (path:gsub('%.git$', ''))
end

--- The kind of forge `host` is, if one is known
---@param host string
---@return DyForgeKind?
function M.kind_of(host)
  if host == 'github.com' or host:match('^github%.') then return 'github' end
  if host == 'gitlab.com' or host:match('gitlab') then return 'gitlab' end
  return nil
end

--- Run git in `dir` and wait, the first line of its output or nil
---@param dir string
---@param args string[]
---@param on_done fun(output: string?) Its output trimmed, nil on failure
local function git(dir, args, on_done)
  local ok = pcall(
    vim.system,
    vim.list_extend({ 'git' }, args),
    { cwd = dir, text = true, timeout = 5000 },
    function(result)
      vim.schedule(function()
        local output = vim.trim(result.stdout or '')
        on_done(result.code == 0 and output ~= '' and output or nil)
      end)
    end
  )
  -- Answered later even when git cannot start, as every other answer is
  if not ok then vim.schedule(function() on_done(nil) end) end
end

--- The first remote of `urls` on a forge this knows, in `M.REMOTES` order
---@param urls table<string, string> Clone URL by remote name
---@return DyForgeRemote?
function M.pick_remote(urls)
  for _, name in ipairs(M.REMOTES) do
    -- Not `urls[name] and M.parse_url(…)`: `and` keeps only the host
    local host, slug
    if urls[name] then
      host, slug = M.parse_url(urls[name])
    end
    local kind = host and M.kind_of(host)
    if kind then
      return { name = name, host = host, slug = slug, kind = kind }
    end
  end
  return nil
end

--- Hand `on_done` the first remote of `dir` on a forge this knows
---@param dir string
---@param on_done fun(remote: DyForgeRemote?)
function M.remote(dir, on_done)
  -- Every remote in one call, rather than one call per name tried
  git(dir, { 'config', '--get-regexp', [[^remote\..*\.url$]] }, function(output)
    local urls = {}
    for name, url in (output or ''):gmatch('remote%.(%S+)%.url%s+(%S+)') do
      urls[name] = url
    end
    on_done(M.pick_remote(urls))
  end)
end

--- Hand `on_done` the branch checked out in `dir`, nil when detached
---@param dir string
---@param on_done fun(branch: string?)
function M.branch(dir, on_done)
  git(dir, { 'symbolic-ref', '--short', 'HEAD' }, on_done)
end

--- Percent-encode `text` for a path segment of a URL
---@param text string
---@return string
function M.encode(text)
  return (
    text:gsub(
      '[^%w%.%-_~]',
      function(char) return ('%%%02X'):format(char:byte()) end
    )
  )
end

--- Call `endpoint` of the API of `remote`, through its CLI, and hand
--- `on_done` the decoded answer or why there is none
---@param remote DyForgeRemote
---@param endpoint string Relative, as the CLI takes it: `repos/o/r/pulls`
---@param on_done fun(data: any?, err: string?)
function M.api(remote, endpoint, on_done)
  local cli = remote.kind == 'github' and 'gh' or 'glab'
  if vim.fn.executable(cli) ~= 1 then
    return on_done(nil, cli .. ' is not installed')
  end
  local command = { cli, 'api', '--hostname', remote.host, endpoint }
  local ok, err = pcall(
    vim.system,
    command,
    { text = true, timeout = M.TIMEOUT },
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          local msg = vim.trim(result.stderr or '')
          if msg == '' then
            msg = ('%s api exited %d'):format(cli, result.code)
          end
          return on_done(nil, msg)
        end
        local decoded, data = pcall(
          vim.json.decode,
          result.stdout or '',
          { luanil = { object = true, array = true } }
        )
        if not decoded then
          return on_done(nil, cli .. ' api answered with something not JSON')
        end
        on_done(data)
      end)
    end
  )
  if not ok then on_done(nil, tostring(err)) end
end

return M
