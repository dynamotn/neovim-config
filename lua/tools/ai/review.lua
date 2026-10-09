--- A review of the staged diff, before it is committed
---
--- The diff is read from git and checked by `tools.ai.check`, as for a
--- commit message, then sent to the chat of `DyNeo.ai.target`, where the
--- answer can be talked over.
local M = {}

--- The prompt, under `prompts/` of this configuration or of the project's
--- trusted `.nvim` folder
M.PROMPT = 'git/review.md'

local notify = require('util.notify').titled('AI review')

--- The prompt for `change`
---@param prompt DyAiPrompt
---@param change DyAiChange
---@return string
function M.build(prompt, change)
  local values = {
    files = table.concat(change.paths, '\n'),
    diff = change.diff .. (change.cut and ('\n(diff cut at %d KiB)'):format(
      require('tools.ai.git').MAX_DIFF / 1024
    ) or ''),
    -- Longer than any backticks of the diff, which a Markdown change has
    fence = require('tools.ai.prompts').fence(change.diff),
  }
  return (prompt.body:gsub('{(%a+)}', values))
end

--- Review what is staged in the work tree of the current buffer
function M.staged()
  local prompt = require('tools.ai.prompts').template(M.PROMPT)
  if not prompt then
    return notify('No prompt ' .. M.PROMPT, vim.log.levels.ERROR)
  end
  local git = require('tools.ai.git')
  local function fail(reason, where)
    require('util.ai_audit').record('dyai', 'refused', where, 'review staged')
    notify(reason, vim.log.levels.WARN)
  end
  git.root(vim.api.nvim_get_current_buf(), function(root, err)
    if not root then
      return fail(err --[[@as string]], vim.uv.cwd() or '')
    end
    git.change(root, nil, function(change, why)
      if not change then
        return fail(why --[[@as string]], root)
      end
      if change.cut then
        notify(
          ('The diff was cut at %d KiB'):format(git.MAX_DIFF / 1024),
          vim.log.levels.WARN
        )
      end
      require('tools.ai').deliver(
        M.build(prompt, change),
        root,
        ('review of %d staged files'):format(#change.paths)
      )
    end)
  end)
end

return M
