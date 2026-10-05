--- `:checkhealth util` -- what this configuration cannot check for itself
---
--- The scripts under `scripts/` answer the questions that can be asked of the
--- tree: that every tool is named right, that a fresh Neovim starts. What
--- they cannot see is this machine: whether the quarantine in front of Mason
--- and lazy.nvim is the one actually running, whether the windows it is held
--- to still agree with the ones bun and uv read, which guard of `util.ai_guard`
--- found nothing to wrap, and which of the tools that never come from Mason
--- are missing here.
---
--- Every check hands back a level and a line, and `check()` only prints them,
--- so the specs can read the same answers without a health buffer.
local M = {}

local DAY = 24 * 60 * 60

---@alias DyHealthLevel 'ok'|'warn'|'error'|'info'
---@alias DyHealthEntry { level: DyHealthLevel, message: string }
---@alias DyHealthSection { title: string, entries: DyHealthEntry[] }

---@param level DyHealthLevel
---@param message string
---@return DyHealthEntry
local function entry(level, message) return { level = level, message = message } end

---@param path string
---@return string?
local function read(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or type(lines) ~= 'table' then return nil end
  return table.concat(lines, '\n')
end

---@return string
local function config_home()
  return vim.env.XDG_CONFIG_HOME
    or vim.fs.joinpath(vim.env.HOME or '~', '.config')
end

---@param seconds integer
---@return string
local function days(seconds) return ('%.0f days'):format(seconds / DAY) end

--- The window every side of the quarantine is held to
---@return integer
local function window()
  local ok, lazy_quarantine = pcall(require, 'tools.lazy-quarantine')
  return ok and lazy_quarantine.window or 7 * DAY
end

--- Whether Mason is resolving its registry through the quarantine, and how
--- old the snapshot it settled on is
---@return DyHealthEntry[]
local function mason_quarantine()
  local entries = {}
  local ok, settings = pcall(require, 'mason.settings')
  if not ok then
    table.insert(
      entries,
      entry('info', 'mason.nvim is not loaded yet; run :Mason and ask again')
    )
    return entries
  end

  local providers = (settings.current or {}).providers or {}
  if vim.list_contains(providers, 'tools.mason-quarantine') then
    table.insert(
      entries,
      entry('ok', 'Mason resolves its registry through tools.mason-quarantine')
    )
  else
    table.insert(
      entries,
      entry(
        'error',
        'tools.mason-quarantine is not in the Mason `providers` setting: '
          .. 'the registry snapshot is whatever was released last'
      )
    )
  end

  local firewall = (settings.current or {}).firewall or {}
  table.insert(
    entries,
    firewall.enabled
        and entry(
          'ok',
          'Socket Firewall stands in front of the npm and PyPI installs'
        )
      or entry(
        'warn',
        'The Socket Firewall is off, so only the quarantine stands between '
          .. 'an install and the registry'
      )
  )

  local root = (settings.current or {}).install_root_dir
    or vim.fs.joinpath(vim.fn.stdpath('data') --[[@as string]], 'mason')
  local info = read(
    vim.fs.joinpath(
      root,
      'registries',
      'github',
      'mason-org',
      'mason-registry',
      'info.json'
    )
  )
  if not info then
    table.insert(
      entries,
      entry('info', 'No registry snapshot on this machine yet')
    )
    return entries
  end

  local decoded_ok, decoded = pcall(vim.json.decode, info)
  local version = decoded_ok and type(decoded) == 'table' and decoded.version
  if type(version) ~= 'string' then
    table.insert(entries, entry('warn', 'The registry snapshot has no version'))
    return entries
  end
  -- Every mason-registry release is tagged with the date it was cut.
  local year, month, day = version:match('^(%d%d%d%d)-(%d%d)-(%d%d)')
  if not year then
    table.insert(
      entries,
      entry(
        'info',
        ('Registry snapshot %s, of no readable date'):format(version)
      )
    )
    return entries
  end
  local age = os.difftime(
    os.time(),
    os.time({
      year = tonumber(year),
      month = tonumber(month),
      day = tonumber(day),
      hour = 12,
    })
  )
  table.insert(
    entries,
    entry(
      age >= window() and 'ok' or 'warn',
      ('Registry snapshot %s, %s old'):format(version, days(age))
    )
  )
  return entries
end

--- Whether lazy.nvim is still calling the wrapper the quarantine put in place
---@return DyHealthEntry
local function lazy_quarantine()
  local ok, quarantine = pcall(require, 'tools.lazy-quarantine')
  if not ok then
    return entry('error', 'tools.lazy-quarantine cannot be loaded')
  end
  if quarantine.installed() then
    return entry(
      'ok',
      ('Plugin updates wait %s, through lazy.nvim `get_target`'):format(
        days(quarantine.window)
      )
    )
  end
  return entry(
    'error',
    'lazy.nvim is not calling the quarantine: `get_target` was renamed or '
      .. 'wrapped by something else, and plugin updates are not held back'
  )
end

--- The windows bun and uv read, which the Mason installs go through
---@return DyHealthEntry[]
local function tool_windows()
  local entries = {}
  local expected = window()

  local bunfig = read(vim.fs.joinpath(config_home(), '.bunfig.toml'))
  if not bunfig then
    table.insert(entries, entry('info', 'No .bunfig.toml; bun installs unheld'))
  else
    local seconds = tonumber(bunfig:match('minimumReleaseAge%s*=%s*(%d+)'))
    if not seconds then
      table.insert(
        entries,
        entry('warn', '.bunfig.toml sets no `minimumReleaseAge`')
      )
    else
      table.insert(
        entries,
        entry(
          seconds >= expected and 'ok' or 'warn',
          ('bun holds a package for %s'):format(days(seconds))
        )
      )
    end
  end

  local uv = read(vim.fs.joinpath(config_home(), 'uv', 'uv.toml'))
  if not uv then
    table.insert(entries, entry('info', 'No uv.toml; uv installs unheld'))
    return entries
  end
  local value = uv:match('exclude%-newer%s*=%s*"([^"]+)"')
  if not value then
    table.insert(entries, entry('warn', 'uv.toml sets no `exclude-newer`'))
    return entries
  end
  local count = tonumber(value:match('^(%d+)%s*day'))
  if not count then
    table.insert(
      entries,
      entry('info', ('uv holds a package until %s'):format(value))
    )
    return entries
  end
  table.insert(
    entries,
    entry(
      count * DAY >= expected and 'ok' or 'warn',
      ('uv holds a package for %s'):format(days(count * DAY))
    )
  )
  return entries
end

--- Which guard of `util.ai_guard` found its plugin, and what the current
--- buffer would be held back for
---@return DyHealthEntry[]
local function ai_guard()
  local entries = {}
  local ok, guard = pcall(require, 'util.ai_guard')
  if not ok then return { entry('error', 'util.ai_guard cannot be loaded') } end

  local names = vim.tbl_keys(guard.status)
  table.sort(names)
  if #names == 0 then
    table.insert(
      entries,
      entry('info', 'No AI integration has loaded yet, so nothing is wrapped')
    )
  end
  for _, name in ipairs(names) do
    table.insert(
      entries,
      guard.status[name] == 'guarded' and entry('ok', name .. ' is guarded')
        or entry('warn', name .. ' was not found, and is left unguarded')
    )
  end

  table.insert(
    entries,
    vim.fn.executable('betterleaks') == 1
        and entry(
          'ok',
          'betterleaks is installed, and its findings hold a buffer back too'
        )
      or entry(
        'warn',
        'betterleaks is not installed, so only the patterns below are searched for'
      )
  )

  local sensitive_config = require('config.sensitive')
  table.insert(
    entries,
    entry(
      'info',
      ('%d name rules, %d directory rules, %d credential formats, %d secret key names'):format(
        #sensitive_config.name_patterns,
        vim.tbl_count(sensitive_config.dirs),
        #sensitive_config.content_patterns,
        #sensitive_config.key_patterns
      )
    )
  )

  local sensitive = require('util.sensitive')
  local bufnr = vim.api.nvim_get_current_buf()
  local reasons = sensitive.reasons(bufnr, { ignore_waiver = true })
  if #reasons == 0 then
    table.insert(entries, entry('info', 'This buffer may be sent to an AI'))
  elseif sensitive.is_allowed(bufnr) then
    table.insert(
      entries,
      entry(
        'warn',
        ':AiGuardAllow waived this buffer, which would otherwise be held back: '
          .. table.concat(reasons, ', ')
      )
    )
  else
    table.insert(
      entries,
      entry('info', 'This buffer is held back: ' .. table.concat(reasons, ', '))
    )
  end
  return entries
end

--- Tools that never come from Mason, and whether this machine has them
---
--- `mason.enabled = false` says the tool ships with a language toolchain, the
--- system or a package manager Mason does not speak. A missing one is not an
--- error -- the formatter or linter is simply skipped -- so it is reported as
--- what it is: a tool this machine does not have.
---@return DyHealthEntry[]
local function system_tools()
  local ok, languages = pcall(require, 'config.languages')
  if not ok then
    return { entry('error', 'config.languages cannot be loaded') }
  end

  local wanted = _G.enabled_languages or vim.tbl_keys(languages)
  local missing, seen = {}, {}
  for _, name in ipairs(vim.list_extend({ '*' }, wanted)) do
    for _, field in ipairs({
      'linters',
      'formatters',
      'lsp_servers',
      'dap',
      'null_ls',
    }) do
      for _, tool in ipairs((languages[name] or {})[field] or {}) do
        local mason = type(tool) == 'table' and tool.mason or nil
        local command = type(tool) == 'table' and (tool.command or tool[1])
        if
          mason
          and mason.enabled == false
          and type(command) == 'string'
          and not seen[command]
        then
          seen[command] = true
          if vim.fn.executable(command) == 0 then
            table.insert(missing, command)
          end
        end
      end
    end
  end

  if #missing == 0 then
    return { entry('ok', 'Every tool Mason does not install is on $PATH') }
  end
  table.sort(missing)
  return {
    entry(
      'info',
      ('Not on $PATH, so their linter or formatter is skipped: %s'):format(
        table.concat(missing, ', ')
      )
    ),
  }
end

--- The programs the README asks for
---@return DyHealthEntry[]
local function requirements()
  local entries = {}
  local required = { 'git', 'curl', 'tar', 'unzip', 'gzip' }
  local optional = {
    rg = 'the pickers and the ripgrep completion source',
    fd = 'the file pickers',
    ['tree-sitter'] = 'building Treesitter parsers',
    cc = 'building Treesitter parsers',
    gh = 'the GitHub API, which the Mason quarantine asks first',
  }
  for _, command in ipairs(required) do
    table.insert(
      entries,
      vim.fn.executable(command) == 1 and entry('ok', command .. ' found')
        or entry('error', command .. ' is missing')
    )
  end
  local names = vim.tbl_keys(optional)
  table.sort(names)
  for _, command in ipairs(names) do
    table.insert(
      entries,
      vim.fn.executable(command) == 1 and entry('ok', command .. ' found')
        or entry(
          'warn',
          ('%s is missing, needed for %s'):format(command, optional[command])
        )
    )
  end
  return entries
end

--- Everything `:checkhealth util` reports, section by section
---@return DyHealthSection[]
function M.report()
  local quarantine = vim.list_extend(mason_quarantine(), { lazy_quarantine() })
  return {
    {
      title = ('Supply chain quarantine (%s)'):format(days(window())),
      entries = vim.list_extend(quarantine, tool_windows()),
    },
    { title = 'AI guard', entries = ai_guard() },
    { title = 'Tools from the system', entries = system_tools() },
    { title = 'Requirements', entries = requirements() },
  }
end

--- What `:checkhealth util` calls
function M.check()
  for _, section in ipairs(M.report()) do
    vim.health.start(section.title)
    for _, item in ipairs(section.entries) do
      vim.health[item.level](item.message)
    end
  end
end

return M
