--- Jira from the editor, through jira-cli
---
--- The completion source in `tools.completion.jira` answers one question --
--- which issue a commit message is about. The rest of a day with an issue
--- tracker is a handful of small chores done in a browser tab: find the
--- issues assigned, start a branch for one, move it along, log the time it
--- took. Each is one `jira` command, so each is one action here, on the issue
--- picked or the one the current branch is named after.
---
--- jira-cli keeps its own configuration and credentials (`jira init`); none
--- of it is read here.
local M = {}

--- How an issue key looks: a project key, a dash, a number
M.KEY_PATTERN = '%u[%u%d_]+%-%d+'

--- The issues `:DyJira` lists when asked nothing else
M.DEFAULT_JQL =
  'assignee = currentUser() AND resolution = Unresolved ORDER BY updated DESC'

--- The prefix of a branch started for an issue, by its type
---
--- The Conventional Commits types the repositories here already use, so the
--- branch reads like the commits that will land on it.
M.BRANCH_PREFIXES = {
  Bug = 'fix',
  Defect = 'fix',
  Incident = 'fix',
  Documentation = 'docs',
  Chore = 'chore',
  Spike = 'chore',
}

--- The prefix for any type not listed in `BRANCH_PREFIXES`
M.DEFAULT_PREFIX = 'feat'

--- Longest the summary part of a branch name gets
local SLUG_WIDTH = 40

--- Milliseconds a `jira` command is given before it is given up on
M.RUN_TIMEOUT = 30000

---@class DyJiraIssue
---@field key string
---@field type string
---@field status string
---@field summary string

---@param msg string
---@param level? integer
local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'Jira' })
end

--- The columns `parse` reads, in this order; the summary comes last so a
--- delimiter inside it stays part of it
local COLUMNS = 'key,type,status,summary'

--- The issues in the output of `jira issue list --plain --no-headers`
---@param lines string[]
---@return DyJiraIssue[]
function M.parse(lines)
  local issues = {}
  for _, line in ipairs(lines) do
    local key, type, status, summary =
      line:match('^%s*(%S+)\t+([^\t]*)\t+([^\t]*)\t+(.-)%s*$')
    if key and key:match('^' .. M.KEY_PATTERN .. '$') then
      table.insert(issues, {
        key = key,
        type = vim.trim(type),
        status = vim.trim(status),
        summary = summary,
      })
    end
  end
  return issues
end

--- `text` as the part of a branch name it can be: lowercase ASCII words
--- joined by dashes, short enough to read
---
--- Accents are dropped rather than the letters carrying them, so a summary in
--- Vietnamese still reads (`Sửa lỗi đăng nhập` becomes `sua-loi-dang-nhap`).
---@param text string
---@return string
function M.slug(text)
  -- `đ` has no decomposition to strip an accent from
  text = text:gsub('đ', 'd'):gsub('Đ', 'D')
  local ascii = vim.fn.iconv(text, 'utf-8', 'ascii//TRANSLIT')
  if ascii == '' then ascii = text end
  local slug =
    ascii:lower():gsub('[^%w]+', '-'):gsub('^%-+', ''):gsub('%-+$', '')
  if #slug > SLUG_WIDTH then
    slug = slug:sub(1, SLUG_WIDTH)
    -- A word cut in half reads worse than one left out
    slug = slug:match('^(.*)%-[^%-]*$') or slug
  end
  return slug
end

--- The branch to start for `issue`: `<type>/<KEY>-<summary>`
---@param issue DyJiraIssue
---@return string
function M.branch_name(issue)
  local prefix = M.BRANCH_PREFIXES[issue.type] or M.DEFAULT_PREFIX
  local slug = M.slug(issue.summary or '')
  return ('%s/%s%s'):format(prefix, issue.key, slug ~= '' and '-' .. slug or '')
end

--- The issue key a branch is named after, if any
---
--- Only where `branch_name` puts it: opening the branch or a part of it,
--- whole or followed by its slug. Anywhere else, `fix/CVE-2024-3094-xz`
--- would name issue `CVE-2024`, and `feat/myABC-1` issue `ABC-1`.
---@param branch string
---@return string?
function M.key_of(branch)
  for part in branch:gmatch('[^/]+') do
    local key = part:match('^(' .. M.KEY_PATTERN .. ')$')
      -- A slug, not more digits: `CVE-2024-3094` is no key
      or part:match('^(' .. M.KEY_PATTERN .. ')%-[^%d]')
    if key then return key end
  end
end

--- The repository the current buffer is in, or the working directory
---@return string
local function repository()
  return vim.fs.root(0, '.git') or vim.uv.cwd() --[[@as string]]
end

--- The branch checked out, or nil outside a repository and when detached
---@return string?
function M.current_branch()
  if vim.fn.executable('git') ~= 1 then return nil end
  local result = vim
    .system({ 'git', '-C', repository(), 'branch', '--show-current' }, { text = true })
    :wait(5000)
  local branch = result.code == 0 and vim.trim(result.stdout or '') or ''
  return branch ~= '' and branch or nil
end

--- The issue the current branch is named after
---@return string?
function M.current_key()
  local branch = M.current_branch()
  return branch and M.key_of(branch)
end

--- Run `jira` with `args`, and hand its output to `on_done` on the main loop
---@param args string[]
---@param on_done fun(ok: boolean, lines: string[], err: string)
function M.run(args, on_done)
  if vim.fn.executable('jira') ~= 1 then
    return on_done(
      false,
      {},
      'jira-cli is not installed: open a commit message once and Mason '
        .. 'installs it, or run :MasonInstall jira'
    )
  end
  -- jira-cli waits on the network for as long as it takes, and with no
  -- server to reach that is forever: nothing would ever be reported
  vim.system(
    vim.list_extend({ 'jira' }, args),
    { text = true, timeout = M.RUN_TIMEOUT },
    function(result)
      vim.schedule(function()
        local err = vim.trim(result.stderr or '')
        if result.signal ~= 0 and err == '' then
          err = ('jira gave no answer within %g seconds'):format(
            M.RUN_TIMEOUT / 1000
          )
        end
        on_done(
          result.code == 0,
          vim.split(result.stdout or '', '\n', { trimempty = true }),
          err
        )
      end)
    end
  )
end

--- The issues matching `jql`; none and why when listing failed
---@param jql string
---@param on_done fun(issues: DyJiraIssue[], err: string?)
---@param opts? { quiet?: boolean } `quiet`: leave saying a failure to the caller
function M.list(jql, on_done, opts)
  M.run({
    'issue',
    'list',
    '--plain',
    '--no-headers',
    '--columns',
    COLUMNS,
    '--paginate',
    '100',
    '--jql',
    jql,
  }, function(ok, lines, err)
    if not ok then
      if not (opts and opts.quiet) then
        notify('Listing issues failed: ' .. err, vim.log.levels.ERROR)
      end
      return on_done({}, err)
    end
    on_done(M.parse(lines))
  end)
end

--- Report the outcome of a `jira` command that changes something
---@param done string What to say when it worked
---@return fun(ok: boolean, lines: string[], err: string)
local function report(done)
  return function(ok, _, err)
    if ok then return notify(done) end
    notify(err ~= '' and err or 'jira failed', vim.log.levels.ERROR)
  end
end

--- Start a branch for `issue`, or switch to it when it is there already
---
--- The name is offered for editing first: the prefix guessed from the type
--- is a guess.
---@param issue DyJiraIssue
function M.branch(issue)
  vim.ui.input(
    { prompt = 'Branch: ', default = M.branch_name(issue) },
    function(name)
      if not name or vim.trim(name) == '' then return end
      name = vim.trim(name)
      local dir = repository()
      local exists = vim
        .system({
          'git',
          '-C',
          dir,
          'rev-parse',
          '--verify',
          '--quiet',
          'refs/heads/' .. name,
        })
        :wait(5000).code == 0
      local args = exists and { 'switch', name } or { 'switch', '-c', name }
      -- Asynchronous and with no deadline: `:wait()` SIGKILLs on timeout,
      -- and a checkout killed half-way leaves `index.lock` behind
      vim.system(
        vim.list_extend({ 'git', '-C', dir }, args),
        { text = true },
        vim.schedule_wrap(function(result)
          if result.code ~= 0 then
            return notify(vim.trim(result.stderr or ''), vim.log.levels.ERROR)
          end
          notify((exists and 'Switched to ' or 'Started ') .. name)
        end)
      )
    end
  )
end

--- Log time spent on `key`, asked for along with a comment
---@param key string
function M.worklog(key)
  vim.ui.input({ prompt = key .. ' time spent (2h 30m): ' }, function(spent)
    if not spent or vim.trim(spent) == '' then return end
    vim.ui.input({ prompt = key .. ' comment (optional): ' }, function(comment)
      if comment == nil then return end
      local args =
        { 'issue', 'worklog', 'add', key, vim.trim(spent), '--no-input' }
      if vim.trim(comment) ~= '' then
        vim.list_extend(args, { '--comment', vim.trim(comment) })
      end
      M.run(args, report(('Logged %s on %s'):format(vim.trim(spent), key)))
    end)
  end)
end

--- Move `key` to another state, asked for
---
--- The states are the workflow's own and differ from project to project, so
--- they are typed rather than picked; a state the workflow has no transition
--- to is jira-cli's to turn down.
---@param key string
---@param default? string
function M.move(key, default)
  vim.ui.input(
    { prompt = key .. ' move to: ', default = default or 'In Progress' },
    function(state)
      if not state or vim.trim(state) == '' then return end
      M.run(
        { 'issue', 'move', key, vim.trim(state) },
        report(('Moved %s to %s'):format(key, vim.trim(state)))
      )
    end
  )
end

--- Open `key` in the browser
---@param key string
function M.open(key) M.run({ 'open', key }, report('Opened ' .. key)) end

--- Show `key` in a split, as Markdown
---@param key string
function M.view(key)
  M.run(
    { 'issue', 'view', key, '--plain', '--comments', '5' },
    function(ok, lines, err)
      if not ok then return notify(err, vim.log.levels.ERROR) end
      vim.cmd('botright new')
      local bufnr = vim.api.nvim_get_current_buf()
      vim.bo[bufnr].buftype = 'nofile'
      vim.bo[bufnr].bufhidden = 'wipe'
      vim.bo[bufnr].swapfile = false
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.bo[bufnr].modifiable = false
      vim.bo[bufnr].filetype = 'markdown'
      vim.keymap.set(
        'n',
        'q',
        '<cmd>close<cr>',
        { buffer = bufnr, nowait = true }
      )
    end
  )
end

--- Put `key` at the cursor of the window the picker was opened from
---@param key string
function M.insert(key) vim.api.nvim_put({ key }, 'c', true, true) end

---@alias DyJiraAction 'branch'|'worklog'|'move'|'open'|'view'|'insert'|'copy'

--- What each action is called in the menu, in the order it is offered
---@type { [1]: DyJiraAction, [2]: string }[]
M.ACTIONS = {
  { 'branch', 'Start a branch' },
  { 'move', 'Move to another state' },
  { 'worklog', 'Log work' },
  { 'view', 'View' },
  { 'open', 'Open in the browser' },
  { 'insert', 'Insert the key' },
  { 'copy', 'Copy the key' },
}

--- Do `action` on `issue`
---@param action DyJiraAction
---@param issue DyJiraIssue
function M.act(action, issue)
  if action == 'branch' then return M.branch(issue) end
  if action == 'copy' then
    vim.fn.setreg('+', issue.key)
    return notify('Copied ' .. issue.key)
  end
  M[action](issue.key)
end

--- Ask which action to do on `issue`
---@param issue DyJiraIssue
function M.menu(issue)
  vim.ui.select(M.ACTIONS, {
    prompt = issue.key .. ' ' .. issue.summary,
    format_item = function(entry) return entry[2] end,
  }, function(entry)
    if entry then M.act(entry[1], issue) end
  end)
end

--- Pick an issue among those matching `jql`, then do `action` on it, or ask
---@param opts? { jql?: string, action?: DyJiraAction, title?: string }
function M.pick(opts)
  opts = opts or {}
  local jql = opts.jql or M.DEFAULT_JQL
  M.list(jql, function(issues)
    if #issues == 0 then return notify('No issues match ' .. jql) end
    local width = 0
    for _, issue in ipairs(issues) do
      width = math.max(width, #issue.key)
    end
    Snacks.picker.pick({
      title = opts.title or 'Jira',
      items = vim.tbl_map(
        function(issue)
          return vim.tbl_extend('force', issue, {
            text = table.concat(
              { issue.key, issue.status, issue.summary },
              ' '
            ),
          })
        end,
        issues
      ),
      format = function(item)
        return {
          { item.key .. (' '):rep(width - #item.key), 'SnacksPickerLabel' },
          { '  ' },
          { item.status, 'SnacksPickerComment' },
          { '  ' },
          { item.summary },
        }
      end,
      preview = function(ctx)
        Snacks.picker.preview.cmd(
          { 'jira', 'issue', 'view', ctx.item.key, '--plain' },
          ctx,
          { ft = 'markdown' }
        )
      end,
      confirm = function(picker, item)
        picker:close()
        if not item then return end
        if opts.action then return M.act(opts.action, item) end
        M.menu(item)
      end,
      actions = {
        jira_branch = function(picker, item)
          picker:close()
          if item then M.act('branch', item) end
        end,
        jira_open = function(picker, item)
          picker:close()
          if item then M.act('open', item) end
        end,
        jira_insert = function(picker, item)
          picker:close()
          if item then M.act('insert', item) end
        end,
      },
      win = {
        input = {
          keys = {
            ['<C-b>'] = {
              'jira_branch',
              mode = { 'n', 'i' },
              desc = 'Start a branch',
            },
            ['<C-o>'] = {
              'jira_open',
              mode = { 'n', 'i' },
              desc = 'Open in the browser',
            },
            ['<C-y>'] = {
              'jira_insert',
              mode = { 'n', 'i' },
              desc = 'Insert the key',
            },
          },
        },
      },
    })
  end)
end

--- Do `action` on the issue of the current branch, or pick one to do it on
---@param action DyJiraAction
---@param key? string Given on the command line
function M.on_issue(action, key)
  local from_branch = key == nil
  key = key or M.current_key()
  if key then
    -- Only the branch checked out says there is one already: a key given on
    -- the command line is the issue to start one for
    if action == 'branch' and from_branch then
      return notify('Already on a branch of ' .. key, vim.log.levels.WARN)
    end
    return M.act(action, { key = key, type = '', status = '', summary = '' })
  end
  M.pick({ action = action, title = 'Jira: ' .. action })
end

--- The subcommands of `:DyJira`
M.SUBCOMMANDS =
  { 'search', 'branch', 'worklog', 'move', 'open', 'view', 'insert', 'copy' }

--- `:DyJira [{subcommand} [{args}]]`
---@param args { fargs: string[] }
function M.command(args)
  local sub, rest = args.fargs[1], vim.list_slice(args.fargs, 2)
  if not sub then return M.pick() end
  if sub == 'search' then
    if #rest > 0 then
      return M.pick({ jql = table.concat(rest, ' '), title = 'Jira search' })
    end
    return vim.ui.input({ prompt = 'JQL: ' }, function(jql)
      if jql and vim.trim(jql) ~= '' then
        M.pick({ jql = jql, title = 'Jira search' })
      end
    end)
  end
  if not vim.tbl_contains(M.SUBCOMMANDS, sub) then
    return notify('Unknown subcommand: ' .. sub, vim.log.levels.ERROR)
  end
  M.on_issue(sub --[[@as DyJiraAction]], rest[1])
end

return M
