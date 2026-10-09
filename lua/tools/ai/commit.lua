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

--- Subjects of recent commits given as examples of the repository's style
M.HISTORY = 10

--- File name of the prompt, under `prompts/` of this configuration or of the
--- project's trusted `.nvim` folder
M.PROMPT = 'git/commit.md'

local notify = require('util.notify').titled('AI commit')

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
      require('tools.ai.git').MAX_DIFF / 1024
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
  local prompt = require('tools.ai.prompts').template(M.PROMPT)
  if not prompt then
    notify('No prompt ' .. M.PROMPT, vim.log.levels.ERROR)
    return
  end
  local git = require('tools.ai.git')
  local function fail(reason, where)
    require('util.ai_audit').record(
      'dyai',
      'refused',
      where or vim.api.nvim_buf_get_name(bufnr),
      'commit'
    )
    notify(reason, vim.log.levels.WARN)
  end
  git.root(bufnr, function(root, err)
    if not root then
      return fail(err --[[@as string]])
    end
    git.change(root, nil, function(change, why)
      if not change then
        return fail(why --[[@as string]], root)
      end
      git.log(root, { '-' .. M.HISTORY, '--format=%s' }, function(subjects)
        if change.cut then
          notify(
            ('The diff was cut at %d KiB'):format(git.MAX_DIFF / 1024),
            vim.log.levels.WARN
          )
        end
        local text = M.build(prompt, {
          diff = change.diff,
          cut = change.cut,
          paths = change.paths,
          subjects = subjects,
          conventional = git.conventional(root),
        })
        local label = ('commit message of %d staged files'):format(
          #change.paths
        )
        require('tools.ai').headless(text, root, label, function(answer)
          local lines = M.message(answer)
          if #lines > 0 and lines[1] ~= '' then M.insert(bufnr, lines) end
        end)
      end)
    end)
  end)
end

return M
