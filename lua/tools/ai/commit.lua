--- A commit message written by an AI from the staged diff
---
--- A `gitcommit` buffer is always kept from AI: `git commit --verbose` puts
--- the whole diff in it, sensitive files and all. So the buffer is never
--- read. The diff is taken from git, and only goes out once no staged path is
--- sensitive and neither `config.sensitive`'s patterns nor `betterleaks`
--- find a secret in it. A check that cannot run refuses, as a finding would.
---
--- The message is written into the buffer only where nothing has been typed
--- yet; a message already there is replaced only once the user says so.
local M = {}

--- Bytes of staged diff sent; a larger one is cut and the prompt says so
M.MAX_DIFF = 512 * 1024

--- Subjects of recent commits given as examples of the repository's style
M.HISTORY = 10

--- File name of the prompt, under `prompts/` of this configuration or of the
--- project's trusted `.nvim` folder
M.PROMPT = 'git/commit.md'

local notify = require('util.notify').titled('AI commit')

--- The prompt template: the project's own, else the shipped one
---@return DyAiPrompt?
local function template()
  local prompts = require('tools.ai.prompts')
  local project = require('util.project_rtp').current()
  if project then
    local own = prompts.read(project .. '/prompts/' .. M.PROMPT, true)
    if own then return own end
  end
  return prompts.read(prompts.BUILTIN .. '/' .. M.PROMPT, false)
end

--- The work tree of the commit being written in `bufnr`, handed to
--- `on_done`
---
--- The message lives in the git directory, outside the work tree: in `.git`
--- of a plain repository, in `.git/worktrees/<name>` of a linked work tree,
--- which names the work tree in its `gitdir` file, or in `.git/modules/<name>`
--- of a submodule, whose `core.worktree` names it. A buffer outside a git
--- directory is in its work tree already.
---@param bufnr integer
---@param on_done fun(root?: string, err?: string)
function M.root(bufnr, on_done)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local dir = name ~= '' and vim.fs.dirname(name) or vim.uv.cwd() or '.'
  local args = { 'git', 'rev-parse', '--show-toplevel' }
  if name:find('/%.git/') then
    local ok, gitdir = pcall(vim.fn.readfile, dir .. '/gitdir', '', 1)
    if ok and gitdir[1] then
      return on_done(vim.fs.dirname(vim.trim(gitdir[1])))
    elseif dir:match('/%.git$') then
      return on_done(vim.fs.dirname(dir))
    end
    args = { 'git', '--git-dir=' .. dir, 'rev-parse', '--show-toplevel' }
  end
  local system = require('util.system')
  system.run(args, { cwd = dir }, function(result)
    local root = vim.trim(result.stdout)
    if result.code ~= 0 or root == '' then
      return on_done(
        nil,
        'Not in a git work tree: ' .. system.failure(result, 'git')
      )
    end
    on_done(root)
  end)
end

--- What keeps `diff` from going out, if anything: a staged path that is
--- sensitive, or text with the shape of a credential
---@param root string
---@param paths string[]
---@param diff string
---@return string? reason
function M.refusal(root, paths, diff)
  local sensitive = require('util.sensitive')
  for _, path in ipairs(paths) do
    if sensitive.is_sensitive_path(vim.fs.joinpath(root, path)) then
      return ('%s is staged and kept from AI'):format(path)
    end
  end
  -- Every line, removed ones too: a secret the commit takes out is still in
  -- the text that would be sent
  for line in diff:gmatch('[^\n]+') do
    local rule = sensitive.secret_format(line)
    if rule then return ('the staged diff holds a %s'):format(rule) end
  end
end

--- Run `betterleaks` over `diff`, with live validation off so nothing of it
--- reaches a provider, and hand `on_done` why it must not go out, or nil
---@param root string
---@param diff string
---@param on_done fun(reason?: string)
function M.scan(root, diff, on_done)
  require('util.system').run({
    'betterleaks',
    'stdin',
    '--report-format=json',
    '--report-path=-',
    '--exit-code=0',
    '--no-banner',
    '--log-level=error',
    '--validation=false',
    '--redact',
  }, { cwd = root, stdin = diff, timeout = 30 * 1000 }, function(result)
    if result.code ~= 0 or result.cut then
      on_done(
        'betterleaks could not check the diff: '
          .. require('util.system').failure(result, 'betterleaks')
      )
      return
    end
    local ok, findings = pcall(vim.json.decode, result.stdout)
    if not ok or type(findings) ~= 'table' then
      on_done('betterleaks gave a report that does not read')
    elseif #findings > 0 then
      local rules = {}
      for _, finding in ipairs(findings) do
        rules[finding.RuleID or 'finding'] = true
      end
      on_done(
        'betterleaks found '
          .. table.concat(vim.tbl_keys(rules), ', ')
          .. ' in the staged diff'
      )
    else
      on_done(nil)
    end
  end)
end

--- The prompt for `diff`, written in the style of `subjects`
---@param prompt DyAiPrompt
---@param ctx { diff: string, cut: boolean, paths: string[], subjects: string[], conventional: boolean }
---@return string
function M.build(prompt, ctx)
  local values = {
    files = table.concat(ctx.paths, '\n'),
    history = #ctx.subjects > 0 and table.concat(ctx.subjects, '\n')
      or '(no commits yet)',
    convention = ctx.conventional
        and 'The repository enforces Conventional Commits: `type(scope): subject`.'
      or 'Follow the style of the recent subjects.',
    diff = ctx.diff .. (ctx.cut and ('\n(diff cut at %d KiB)'):format(
      M.MAX_DIFF / 1024
    ) or ''),
    -- Longer than any backticks of the diff, which a Markdown change has
    fence = require('tools.ai.prompts').fence(ctx.diff),
  }
  return (prompt.body:gsub('{(%a+)}', values))
end

--- The message an AI answered, without the fence it may have wrapped it in
---@param reply string
---@return string[]
function M.message(reply)
  local lines = vim.split(vim.trim(reply), '\n', { plain = true })
  if lines[1] and lines[1]:match('^```') and lines[#lines] == '```' then
    lines = vim.list_slice(lines, 2, #lines - 1)
  end
  return lines
end

--- Lines before the first comment: what the user has typed of the message
---@param bufnr integer
---@return integer last Line where the message area ends, 0-based, exclusive
---@return boolean empty
local function message_area(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local last, empty = #lines, true
  for i, line in ipairs(lines) do
    if line:match('^#') then
      last = i - 1
      break
    end
    if vim.trim(line) ~= '' then empty = false end
  end
  return last, empty
end

--- Put `lines` in the message area of `bufnr`, asking first when the user
--- has written something there already
---@param bufnr integer
---@param lines string[]
function M.insert(bufnr, lines)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  local _, empty = message_area(bufnr)
  local function put()
    -- The buffer may have changed while the question was up
    local last = message_area(bufnr)
    vim.api.nvim_buf_set_lines(
      bufnr,
      0,
      last,
      false,
      vim.list_extend(vim.deepcopy(lines), { '' })
    )
  end
  if empty then
    put()
    return
  end
  vim.ui.select(
    { 'Replace it', 'Keep mine' },
    { prompt = 'A message is written already' },
    function(choice)
      if choice == 'Replace it' and vim.api.nvim_buf_is_valid(bufnr) then
        put()
      end
    end
  )
end

--- Write the message of the commit being edited in the current buffer
function M.write()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= 'gitcommit' then
    notify('Run it in a commit message (git commit)', vim.log.levels.WARN)
    return
  end
  local prompt = template()
  if not prompt then
    notify('No prompt ' .. M.PROMPT, vim.log.levels.ERROR)
    return
  end
  local system = require('util.system')
  local function fail(reason, where)
    require('util.ai_audit').record(
      'dyai',
      'refused',
      where or vim.api.nvim_buf_get_name(bufnr),
      'commit'
    )
    notify(reason, vim.log.levels.WARN)
  end
  M.root(bufnr, function(root, err)
    if not root then
      return fail(err --[[@as string]])
    end
    local function refuse(reason) fail(reason, root) end
    system.run(
      { 'git', 'diff', '--cached', '--name-only', '-z' },
      { cwd = root },
      function(names)
        if names.code ~= 0 then
          return refuse(system.failure(names, 'git diff'))
        end
        local paths = vim.split(names.stdout, '\0', { trimempty = true })
        if #paths == 0 then return refuse('Nothing is staged') end
        M.collect(root, paths, prompt, bufnr, refuse)
      end
    )
  end)
end

--- Read the diff and history, check them, and ask for the message
---@param root string
---@param paths string[]
---@param prompt DyAiPrompt
---@param bufnr integer
---@param fail fun(reason: string)
function M.collect(root, paths, prompt, bufnr, fail)
  local system = require('util.system')
  system.run({
    'git',
    'diff',
    '--cached',
    '--no-color',
    '--no-ext-diff',
  }, { cwd = root, max_bytes = M.MAX_DIFF }, function(diff)
    if diff.code ~= 0 and not diff.cut then
      return fail(system.failure(diff, 'git diff'))
    end
    local reason = M.refusal(root, paths, diff.stdout)
    if reason then return fail(reason) end
    M.scan(root, diff.stdout, function(leak)
      if leak then return fail(leak) end
      system.run(
        { 'git', 'log', '-' .. M.HISTORY, '--format=%s' },
        { cwd = root },
        function(log)
          -- A repository with no commit yet has no history to follow
          local subjects = log.code == 0
              and vim.split(log.stdout, '\n', { trimempty = true })
            or {}
          local conventional = vim.uv.fs_stat(root .. '/.gitlint') ~= nil
            or #vim.fn.glob(root .. '/{.,}commitlint*', true, true) > 0
          if diff.cut then
            notify(
              ('The diff was cut at %d KiB'):format(M.MAX_DIFF / 1024),
              vim.log.levels.WARN
            )
          end
          M.ask(
            root,
            paths,
            bufnr,
            M.build(prompt, {
              diff = diff.stdout,
              cut = diff.cut,
              paths = paths,
              subjects = subjects,
              conventional = conventional,
            })
          )
        end
      )
    end)
  end)
end

--- Hand `text` to `DyNeo.ai.commit_command` and put its answer in `bufnr`
---@param root string
---@param paths string[]
---@param bufnr integer
---@param text string
function M.ask(root, paths, bufnr, text)
  local system = require('util.system')
  local ai = DyNeo.ai or {}
  local cmd = ai.commit_command or { 'claude', '-p' }
  require('util.ai_audit').record(
    'dyai',
    'sent',
    root,
    ('commit: %d staged files'):format(#paths)
  )
  notify('Writing the message with ' .. cmd[1] .. '...')
  system.run(cmd, {
    cwd = root,
    stdin = text,
    timeout = ai.commit_timeout,
    max_bytes = 64 * 1024,
    -- A CLI that wants to ask something must not take over the terminal
    detach = true,
  }, function(result)
    if result.code ~= 0 then
      notify(system.failure(result, cmd[1]), vim.log.levels.ERROR)
      return
    end
    local lines = M.message(result.stdout)
    if #lines == 0 or lines[1] == '' then
      notify(cmd[1] .. ' gave an empty answer', vim.log.levels.WARN)
      return
    end
    M.insert(bufnr, lines)
  end)
end

return M
