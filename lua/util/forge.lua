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
---@return string?
local function git(dir, args)
  local ok, result = pcall(
    function()
      return vim
        .system(vim.list_extend({ 'git' }, args), { cwd = dir, text = true })
        :wait(5000)
    end
  )
  if not ok or result.code ~= 0 then return nil end
  local line = vim.trim(result.stdout or '')
  return line ~= '' and line or nil
end

--- The first remote of `dir` on a forge this knows
---@param dir string
---@return DyForgeRemote?
function M.remote(dir)
  for _, name in ipairs(M.REMOTES) do
    local url = git(dir, { 'remote', 'get-url', name })
    if url then
      local host, slug = M.parse_url(url)
      local kind = host and M.kind_of(host)
      if kind then
        return { name = name, host = host, slug = slug, kind = kind }
      end
    end
  end
  return nil
end

--- The branch checked out in `dir`, nil when detached
---@param dir string
---@return string?
function M.branch(dir) return git(dir, { 'symbolic-ref', '--short', 'HEAD' }) end

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
