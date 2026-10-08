--- A bill of materials for the editor, and the vulnerabilities known in it
---
--- Everything this configuration runs that it did not write comes from two
--- places: the plugins lazy.nvim cloned, each at the commit of the lockfile,
--- and the tools Mason installed, each at the version of its receipt. That
--- is a supply chain like any other, so it is listed like any other -- as a
--- CycloneDX document a scanner can read -- and asked about like any other,
--- of OSV (https://osv.dev), which knows the advisories of npm, PyPI,
--- crates.io, Go and the rest, and the commits of the repositories they name.
---
--- The quarantine in front of both (`tools.lazy-quarantine`,
--- `tools.mason-quarantine`) is about what is new; this is about what is
--- already here, and was found out about after it arrived.
local M = {}

--- The purl types OSV answers for, by the ecosystem they stand for
local OSV_TYPES = {
  npm = true,
  pypi = true,
  cargo = true,
  golang = true,
  gem = true,
  nuget = true,
  composer = true,
  maven = true,
  hex = true,
  pub = true,
}

--- Where OSV takes a batch of questions
M.OSV_URL = 'https://api.osv.dev/v1/querybatch'

---@class DySbomComponent
---@field name string
---@field version string A commit for a plugin, a release for a Mason package
---@field purl? string
---@field source 'lazy.nvim'|'mason'

---@param text string
---@return string
local function encode(text)
  return (
    text:gsub(
      '[^%w%.%-_~]',
      function(char) return ('%%%02X'):format(char:byte()) end
    )
  )
end

---@param text string
---@return string
local function decode(text)
  return (
    text:gsub(
      '%%(%x%x)',
      function(hex) return string.char(tonumber(hex, 16)) end
    )
  )
end

--- The forges a purl has a type of its own for
local FORGES = {
  ['github.com'] = 'github',
  ['gitlab.com'] = 'gitlab',
  ['bitbucket.org'] = 'bitbucket',
}

--- The purl of a plugin cloned from `url`, at `commit`
---
--- A forge purl names the repository; anything else is `generic`, with the
--- clone URL as its `vcs_url` so it can still be found.
---@param name string
---@param url? string
---@param commit string
---@return string
function M.plugin_purl(name, url, commit)
  local host, path
  if url then
    local rest = url:match('^%a[%w+.-]*://(.*)$')
    if rest then
      -- A user in the URL (`https://user@host/...`) is no part of the name
      host, path = rest:gsub('^[^@/]*@', ''):match('^([^/]+)/(.-)/?$')
    else
      host, path = url:match('^[%w_.-]+@([^:]+):(.-)/?$')
    end
  end
  if host and path then
    path = path:gsub('%.git$', '')
    local namespace, repo = path:match('^(.+)/([^/]+)$')
    local forge = FORGES[host:lower()]
    if forge and namespace then
      -- The purl spec lowercases both for GitHub and Bitbucket, and GitLab
      -- paths are case insensitive too
      return ('pkg:%s/%s/%s@%s'):format(
        forge,
        namespace:lower(),
        repo:lower(),
        commit
      )
    end
    return ('pkg:generic/%s@%s?vcs_url=%s'):format(
      encode(name),
      commit,
      encode('git+' .. url .. '@' .. commit)
    )
  end
  return ('pkg:generic/%s@%s'):format(encode(name), commit)
end

--- Read and decode the JSON file at `path`, or nil
---@param path string
---@return table?
local function read_json(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then return nil end
  local decoded, value = pcall(vim.json.decode, table.concat(lines, '\n'))
  return decoded and type(value) == 'table' and value or nil
end

--- The plugins of a lazy.nvim lockfile
---@param lockfile string
---@param urls table<string, string> Plugin name to the URL it was cloned from
---@return DySbomComponent[]
function M.plugins(lockfile, urls)
  local components = {}
  for name, entry in pairs(read_json(lockfile) or {}) do
    if type(entry) == 'table' and type(entry.commit) == 'string' then
      table.insert(components, {
        name = name,
        version = entry.commit,
        purl = M.plugin_purl(name, urls[name], entry.commit),
        source = 'lazy.nvim',
      })
    end
  end
  return components
end

--- The packages Mason installed under `root`, from their receipts
---
--- The receipt keeps the purl the package was installed from, version and
--- all, which is the very thing a bill of materials wants.
---@param root string Mason's install root
---@return DySbomComponent[]
function M.mason(root)
  local components = {}
  local packages = vim.fs.joinpath(root, 'packages')
  for name, kind in vim.fs.dir(packages) do
    if kind == 'directory' then
      local receipt =
        read_json(vim.fs.joinpath(packages, name, 'mason-receipt.json'))
      local id = receipt and vim.tbl_get(receipt, 'source', 'id')
      if receipt and type(id) == 'string' then
        local purl = id:find('^pkg:') and id or nil
        local version = purl
            and purl:match('@([^?#]+)')
            and decode(purl:match('@([^?#]+)'))
          or 'unknown'
        table.insert(components, {
          name = receipt.name or name,
          version = version,
          purl = purl,
          source = 'mason',
        })
      end
    end
  end
  return components
end

--- Everything installed on this machine: lazy.nvim's plugins and Mason's
--- packages, sorted by name
---@return DySbomComponent[]
function M.components()
  local components = {}

  local ok_config, Config = pcall(require, 'lazy.core.config')
  if ok_config and Config.options and Config.options.lockfile then
    local urls = {}
    for name, plugin in pairs(Config.plugins or {}) do
      urls[name] = plugin.url
    end
    vim.list_extend(components, M.plugins(Config.options.lockfile, urls))
  end

  local ok_settings, settings = pcall(require, 'mason.settings')
  local root = ok_settings and settings.current.install_root_dir
    or vim.fs.joinpath(vim.fn.stdpath('data') --[[@as string]], 'mason')
  vim.list_extend(components, M.mason(root))

  table.sort(components, function(a, b)
    if a.name == b.name then return a.source < b.source end
    return a.name < b.name
  end)
  return components
end

--- A random version 4 UUID, for the serial number of a document
---@return string
local function uuid()
  local bytes = { vim.uv.random(16):byte(1, 16) }
  bytes[7] = bit.bor(bit.band(bytes[7], 0x0f), 0x40)
  bytes[9] = bit.bor(bit.band(bytes[9], 0x3f), 0x80)
  local hex = vim.tbl_map(
    function(byte) return ('%02x'):format(byte) end,
    bytes
  )
  return table.concat({
    table.concat(hex, '', 1, 4),
    table.concat(hex, '', 5, 6),
    table.concat(hex, '', 7, 8),
    table.concat(hex, '', 9, 10),
    table.concat(hex, '', 11, 16),
  }, '-')
end

--- The CycloneDX 1.5 document listing `components`
---@param components DySbomComponent[]
---@param now? integer Seconds since the epoch, for the specs
---@return table
function M.bom(components, now)
  return {
    bomFormat = 'CycloneDX',
    specVersion = '1.5',
    serialNumber = 'urn:uuid:' .. uuid(),
    version = 1,
    metadata = {
      timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ', now or os.time()),
      component = {
        type = 'application',
        name = 'DyNeo',
        ['bom-ref'] = 'dyneo',
      },
    },
    components = vim.tbl_map(
      function(component)
        return {
          type = 'library',
          ['bom-ref'] = component.purl
            or (component.source .. ':' .. component.name),
          name = component.name,
          version = component.version,
          purl = component.purl,
          properties = {
            { name = 'dyneo:installed-by', value = component.source },
          },
        }
      end,
      components
    ),
  }
end

--- `value` as indented JSON, when this Neovim can indent it
---@param value table
---@return string
local function to_json(value)
  local ok, json =
    pcall(vim.json.encode, value, { indent = '  ', sort_keys = true })
  return ok and json or vim.json.encode(value)
end

--- What to ask OSV, one question per component it can answer for
---
--- A package is asked about by its purl. A plugin has no ecosystem in OSV,
--- but a commit does: OSV maps the commits of a repository an advisory
--- names onto the ranges it affects.
---@param components DySbomComponent[]
---@return table[] queries
---@return DySbomComponent[] asked The component behind each query
function M.osv_queries(components)
  local queries, asked = {}, {}
  for _, component in ipairs(components) do
    local type = component.purl and component.purl:match('^pkg:([^/]+)/')
    if type and OSV_TYPES[type] then
      table.insert(queries, { package = { purl = component.purl } })
      table.insert(asked, component)
    elseif
      component.source == 'lazy.nvim' and component.version:find('^%x+$')
    then
      table.insert(queries, { commit = component.version })
      table.insert(asked, component)
    end
  end
  return queries, asked
end

---@class DySbomVulnerable
---@field component DySbomComponent
---@field ids string[]

--- The components OSV knows a vulnerability of
---@param asked DySbomComponent[] In the order the queries were sent
---@param response table The decoded answer of the batch query
---@return DySbomVulnerable[]
function M.osv_findings(asked, response)
  local findings = {}
  for index, result in ipairs(response.results or {}) do
    local ids = vim.tbl_map(
      function(vuln) return vuln.id end,
      result.vulns or {}
    )
    if #ids > 0 and asked[index] then
      table.sort(ids)
      table.insert(findings, { component = asked[index], ids = ids })
    end
  end
  return findings
end

--- The report of `findings`, as Markdown lines
---@param findings DySbomVulnerable[]
---@param asked integer How many components were asked about
---@param total integer How many there are
---@return string[]
function M.osv_report(findings, asked, total)
  local lines = {
    ('# Known vulnerabilities: %d'):format(#findings),
    '',
    (
      '%d of %d plugins and packages asked of OSV; the rest have no '
      .. 'ecosystem it covers.'
    ):format(asked, total),
  }
  if #findings > 0 then table.insert(lines, '') end
  for _, finding in ipairs(findings) do
    local component = finding.component
    table.insert(
      lines,
      ('## %s %s (%s)'):format(
        component.name,
        component.version:sub(1, 12),
        component.source
      )
    )
    table.insert(lines, '')
    for _, id in ipairs(finding.ids) do
      table.insert(
        lines,
        ('- %s https://osv.dev/vulnerability/%s'):format(id, id)
      )
    end
    table.insert(lines, '')
  end
  return lines
end

--- A scratch buffer holding `lines`, in a tab of its own
---@param lines string[]
---@param filetype string
local function scratch(lines, filetype)
  vim.cmd('tabnew')
  local bufnr = vim.api.nvim_get_current_buf()
  vim.bo[bufnr].buftype = 'nofile'
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].swapfile = false
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].filetype = filetype
  vim.keymap.set(
    'n',
    'q',
    '<cmd>close<cr>',
    { buffer = bufnr, desc = 'Close', nowait = true }
  )
end

---@param msg string
---@param level? integer
local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'SBOM' })
end

--- Ask OSV about every component, and show what it knows
---
--- One request, the names and versions of what is installed and the commits
--- of the plugins, nothing else of the machine.
function M.osv()
  local components = M.components()
  local queries, asked = M.osv_queries(components)
  if #queries == 0 then return notify('Nothing to ask OSV about') end
  notify(('Asking OSV about %d plugins and packages…'):format(#queries))
  vim.system({
    'curl',
    '--silent',
    '--show-error',
    '--fail',
    '--max-time',
    '60',
    '--header',
    'Content-Type: application/json',
    '--data-binary',
    '@-',
    M.OSV_URL,
  }, {
    text = true,
    stdin = vim.json.encode({ queries = queries }),
  }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        return notify(
          'OSV query failed: ' .. vim.trim(result.stderr or ''),
          vim.log.levels.ERROR
        )
      end
      local ok, response = pcall(vim.json.decode, result.stdout or '')
      if not ok or type(response) ~= 'table' then
        return notify(
          'OSV answered with something that is not JSON',
          vim.log.levels.ERROR
        )
      end
      local findings = M.osv_findings(asked, response)
      if #findings == 0 then
        return notify(
          ('No known vulnerabilities in the %d plugins and packages asked'):format(
            #asked
          )
        )
      end
      scratch(M.osv_report(findings, #asked, #components), 'markdown')
    end)
  end)
end

--- `:DySbom [{path}]`, `:DySbom osv`
---@param args { fargs: string[] }
function M.command(args)
  local target = args.fargs[1]
  if target == 'osv' then return M.osv() end

  local components = M.components()
  local json = to_json(M.bom(components))
  if not target then return scratch(vim.split(json, '\n'), 'json') end
  local path = vim.fn.fnamemodify(vim.fn.expand(target), ':p')
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  vim.fn.writefile(vim.split(json, '\n'), path)
  notify(('%d plugins and packages written to %s'):format(#components, path))
end

return M
