--- What a plugin update would bring in, read before it lands
---
--- `tools.lazy-quarantine` holds a fresh commit back for a week so that a
--- compromised release has time to be caught -- by someone. This is the
--- part of the catching that can be done here: the commits waiting for each
--- plugin, and the lines they add that do what a plugin rarely needs to and
--- an attacker always does -- start a process, load code at runtime, reach
--- the network, read a credential, delete files, hide a blob.
---
--- A flag is a reason to read the diff, not a verdict: a plugin that talks to
--- an LSP or opens a URL does most of these for a living. What matters is a
--- flag nobody expected in a plugin that never did it before.
local M = {}

--- What a line added by an update is flagged for, by Lua pattern
---@type { name: string, patterns: string[] }[]
M.rules = {
  {
    name = 'runs a process',
    patterns = {
      'vim%.system%s*%(',
      'vim%.fn%.system',
      'jobstart%s*%(',
      'termopen%s*%(',
      'io%.popen',
      'os%.execute',
      '%.spawn%s*%(',
    },
  },
  {
    name = 'loads code at runtime',
    patterns = {
      'loadstring%s*%(',
      '%f[%w_.:]load%s*%(',
      'loadfile%s*%(',
      'dofile%s*%(',
      'require%s*%(?%s*[\'"]ffi[\'"]',
    },
  },
  {
    name = 'reaches the network',
    patterns = {
      'https?://',
      '%f[%w]curl%f[%W]',
      '%f[%w]wget%f[%W]',
      'new_tcp',
      'new_udp',
      'getaddrinfo',
    },
  },
  {
    name = 'touches credentials',
    patterns = {
      '%.ssh/',
      '%.gnupg',
      '%.aws/',
      '%.netrc',
      '%.git%-credentials',
      '_TOKEN%f[%W]',
      'id_rsa',
      'id_ed25519',
    },
  },
  {
    name = 'deletes or moves files',
    patterns = {
      'os%.remove',
      'os%.rename',
      'fs_unlink',
      'fs_rmdir',
      'fs_rename',
      'vim%.fn%.delete%s*%(',
      'rm %-[rf][rf]?',
    },
  },
  {
    name = 'carries an encoded blob',
    patterns = { string.rep('[%w+/=]', 160) },
  },
}

--- Files whose change alters what runs on install or build, whatever is in
--- them: lazy.nvim runs `build.lua` and a `build` command as the plugin
--- lands, before any of its Lua is required
local BUILD_FILES = {
  ['build.lua'] = true,
  ['Makefile'] = true,
  ['makefile'] = true,
  ['CMakeLists.txt'] = true,
  ['Cargo.toml'] = true,
  ['go.mod'] = true,
  ['package.json'] = true,
  ['justfile'] = true,
}

--- Directories of a plugin that never run in the editor: its CI, which runs
--- on the forge, and its tests, which lazy.nvim does not run either
local NOT_RUN = {
  '^%.github/',
  '^%.gitlab/',
  '^%.gitlab%-ci%.ya?ml$',
  '^%.forgejo/',
  '^%.gitea/',
  '^%.circleci/',
  '^tests?/',
  '^spec/',
}

--- Whether `path` is something the rules would only cry wolf over: prose --
--- docs, licences, changelogs, where a URL is a link and `rm -rf` an example
--- -- or a file that never runs here
---@param path string
---@return boolean
local function is_ignored(path)
  for _, pattern in ipairs(NOT_RUN) do
    if path:find(pattern) then return true end
  end
  local name = vim.fs.basename(path)
  return path:find('^doc/') ~= nil
    or name:find('%.md$') ~= nil
    or name:find('%.txt$') ~= nil
    or name:find('%.rst$') ~= nil
    or name:find('^LICEN[CS]E') ~= nil
    or name:find('^CHANGELOG') ~= nil
end

--- Whether `text` is a comment and nothing else, which no rule is about
---
--- Vimscript's `"` is left out: in Lua it opens a string, and a table of
--- strings is exactly where a command line hides.
---@param text string
---@return boolean
local function is_comment(text)
  return text:find('^%s*%-%-') ~= nil
    or text:find('^%s*#') ~= nil
    or text:find('^%s*//') ~= nil
end

---@class DyReviewFinding
---@field file string
---@field line? integer
---@field rule string
---@field text? string

--- Flag the lines a diff adds
---
--- `diff` is the output of `git diff --unified=0`, as lines.
---@param diff string[]
---@return DyReviewFinding[]
function M.scan(diff)
  ---@type DyReviewFinding[]
  local findings = {}
  local file, line, in_hunk, skip = nil, 0, false, false

  for _, raw in ipairs(diff) do
    local b_path = raw:match('^diff %-%-git a/.- b/(.*)$')
    if b_path then
      file, in_hunk, skip = b_path, false, is_ignored(b_path)
      if BUILD_FILES[vim.fs.basename(file)] or file:find('%.rockspec$') then
        table.insert(findings, { file = file, rule = 'changes the build' })
      end
    elseif raw:find('^Binary files ') then
      local binary = raw:match(' and b/(.*) differ$')
      if binary then
        table.insert(findings, { file = binary, rule = 'adds a binary file' })
      end
    elseif raw:find('^@@ ') then
      in_hunk = true
      line = tonumber(raw:match('^@@ %-%d+,?%d* %+(%d+)')) or 0
    elseif in_hunk and file and raw:sub(1, 1) == '+' then
      local text = raw:sub(2)
      if not skip and not is_comment(text) then
        for _, rule in ipairs(M.rules) do
          for _, pattern in ipairs(rule.patterns) do
            if text:find(pattern) then
              table.insert(findings, {
                file = file,
                line = line,
                rule = rule.name,
                text = vim.trim(text),
              })
              break
            end
          end
        end
      end
      line = line + 1
    end
  end
  return findings
end

--- Run `git` in `dir`, and hand back its output as lines, or nil on failure
---@param dir string
---@param args string[]
---@return string[]?
local function git(dir, args)
  local command = { 'git', '-C', dir }
  vim.list_extend(command, args)
  local ok, result = pcall(
    function() return vim.system(command, { text = true }):wait(30000) end
  )
  if not ok or result.code ~= 0 then return nil end
  return vim.split(result.stdout or '', '\n', { trimempty = true })
end

--- The commits `row` would bring in, newest first, as `short date subject`
---@param row DyPendingUpdate
---@return string[]
function M.commits(row)
  return git(row.dir, {
    'log',
    '--no-color',
    '--format=%h %cs %s',
    row.from .. '..' .. row.to,
  }) or {}
end

--- What the commits of `row` add, flagged
---@param row DyPendingUpdate
---@return DyReviewFinding[]
function M.findings(row)
  return M.scan(git(row.dir, {
    'diff',
    '--no-color',
    '--no-ext-diff',
    '--no-renames',
    -- `scan` reads the paths off `a/` and `b/`, which `diff.noprefix` and
    -- `diff.mnemonicPrefix` in a user's config would take away
    '--src-prefix=a/',
    '--dst-prefix=b/',
    '--unified=0',
    row.from,
    row.to,
  }) or {})
end

--- Longest a line of code is quoted in the report
local QUOTE_WIDTH = 72

--- Line numbers listed for a flag raised more than once in a file
local MAX_LINES = 5

---@class DyReviewGroup
---@field file string
---@field rule string
---@field findings DyReviewFinding[]

--- The findings of the same rule in the same file, together, in the order
--- each first turned up
---
--- A schema catalog adds a hundred URLs in one update, each of them a flag;
--- one line saying so reads better than a hundred.
---@param findings DyReviewFinding[]
---@return DyReviewGroup[]
function M.group(findings)
  local groups, by_key = {}, {}
  for _, finding in ipairs(findings) do
    local key = finding.file .. '\0' .. finding.rule
    if not by_key[key] then
      by_key[key] = { file = finding.file, rule = finding.rule, findings = {} }
      table.insert(groups, by_key[key])
    end
    table.insert(by_key[key].findings, finding)
  end
  return groups
end

--- One line of the report for `group`
---@param group DyReviewGroup
---@return string
function M.describe(group)
  local first = group.findings[1]
  local line
  if #group.findings == 1 then
    line = ('- %s  %s'):format(
      first.line and ('%s:%d'):format(group.file, first.line) or group.file,
      group.rule
    )
  else
    local numbers = {}
    for index, finding in ipairs(group.findings) do
      if index > MAX_LINES then
        table.insert(numbers, '…')
        break
      end
      table.insert(numbers, tostring(finding.line))
    end
    line = ('- %s  %s ×%d (lines %s)'):format(
      group.file,
      group.rule,
      #group.findings,
      table.concat(numbers, ', ')
    )
  end
  if first.text then
    local text = first.text
    if vim.fn.strchars(text) > QUOTE_WIDTH then
      text = vim.fn.strcharpart(text, 0, QUOTE_WIDTH) --[[@as string]] .. '…'
    end
    line = line .. ('  `%s`'):format((text:gsub('`', "'")))
  end
  return line
end

--- The report on `rows`, as Markdown lines
---@param rows DyPendingUpdate[]
---@param window integer The quarantine window, in seconds
---@return string[]
function M.report(rows, window)
  local lines = {
    ('# Plugin updates waiting: %d'):format(#rows),
    '',
    (
      'Quarantine window: %d days. `<CR>` on a plugin opens its diff, `q` '
      .. 'closes.'
    ):format(math.floor(window / 86400)),
  }
  if #rows == 0 then
    vim.list_extend(
      lines,
      { '', 'Every plugin is on the commit it would update to.' }
    )
    return lines
  end

  for _, row in ipairs(rows) do
    local commits = M.commits(row)
    local state = row.held
        and ('held %d more days'):format(math.ceil(row.clears / 86400))
      or 'out of quarantine'
    vim.list_extend(lines, {
      '',
      ('## %s  %s..%s  %d commits, %s'):format(
        row.name,
        row.from:sub(1, 7),
        row.to:sub(1, 7),
        #commits,
        state
      ),
      '',
    })
    for index, commit in ipairs(commits) do
      if index > 15 then
        table.insert(lines, ('- … and %d more'):format(#commits - 15))
        break
      end
      table.insert(lines, '- ' .. commit)
    end

    local findings = M.findings(row)
    table.insert(lines, '')
    if #findings == 0 then
      table.insert(lines, 'No flags.')
    else
      table.insert(lines, ('Flags (%d):'):format(#findings))
      for _, group in ipairs(M.group(findings)) do
        table.insert(lines, M.describe(group))
      end
    end
  end
  return lines
end

--- A scratch buffer holding `lines`, in a window of its own
---@param lines string[]
---@param filetype string
---@param open string The command that makes the window
---@return integer bufnr
local function scratch(lines, filetype, open)
  vim.cmd(open)
  local bufnr = vim.api.nvim_get_current_buf()
  vim.bo[bufnr].buftype = 'nofile'
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].swapfile = false
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].filetype = filetype
  vim.keymap.set(
    'n',
    'q',
    '<cmd>close<cr>',
    { buffer = bufnr, desc = 'Close', nowait = true }
  )
  return bufnr
end

--- The whole of what `row` brings in, commit by commit, in a tab
---@param row DyPendingUpdate
function M.open_diff(row)
  local log = git(row.dir, {
    'log',
    '--no-color',
    '--no-ext-diff',
    '--stat',
    '--patch',
    row.from .. '..' .. row.to,
  }) or { 'git log failed in ' .. row.dir }
  scratch(log, 'git', 'tabnew')
end

--- The plugin whose section the cursor is in
---@param bufnr integer
---@return string?
local function section_at_cursor(bufnr)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  for index = row, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, index - 1, index, false)[1]
    local name = line and line:match('^## (%S+)')
    if name then return name end
  end
end

--- `:LazyQuarantine review [{plugin}]`
---
--- Without a plugin, the report on every update waiting; with one, its full
--- diff. A `git log` and a `git diff` per plugin, which is why it is a
--- command and not something shown as updates are checked for.
---@param rows DyPendingUpdate[]
---@param window integer
---@param name? string
function M.show(rows, window, name)
  ---@type table<string, DyPendingUpdate>
  local by_name = {}
  for _, row in ipairs(rows) do
    by_name[row.name] = row
  end

  if name and name ~= '' then
    if not by_name[name] then
      return vim.notify(
        name .. ' has no update waiting',
        vim.log.levels.WARN,
        { title = 'Quarantine' }
      )
    end
    return M.open_diff(by_name[name])
  end

  local bufnr = scratch(M.report(rows, window), 'markdown', 'tabnew')
  vim.keymap.set('n', '<CR>', function()
    local plugin = section_at_cursor(bufnr)
    if plugin and by_name[plugin] then M.open_diff(by_name[plugin]) end
  end, { buffer = bufnr, desc = 'Open the diff of this plugin' })
end

return M
