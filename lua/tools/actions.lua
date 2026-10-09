--- GitHub Actions pinned to the commit they run
---
--- `uses: actions/checkout@v4` runs whatever the tag points at today; a tag
--- moved by whoever took over the repository runs in every workflow that
--- names it, secrets in reach. `:DyActionsPin` rewrites each `uses:` of the
--- workflow to the full commit its ref points at, the ref kept in a
--- comment for Renovate and Dependabot to follow:
---
---     uses: actions/checkout@08eba0b27e820071cde6df949e0beb9ba4906955 # v4
---
--- The commits are asked of GitHub through `gh`. A local action (`./…`),
--- a `docker://` image and a ref already a full commit are left alone.
local M = {}

local forge = require('util.forge')

---@param msg string
---@param level? integer
local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'Actions' })
end

---@class DyActionsUses
---@field head string What comes before the action: `  - uses: `
---@field repo string `owner/repo`
---@field path string A sub-directory of the repository, `/x/y`, or ''
---@field ref string
---@field comment? string The comment after it, if any

--- The `uses:` of `line`, or nil when it names no remote action
---@param line string
---@return DyActionsUses?
function M.parse(line)
  local head, target, rest =
    line:match('^(%s*%-?%s*uses:%s*)["\']?([^%s"\'#]+)["\']?(.*)$')
  if not target or target:match('^%./') or target:match('^docker://') then
    return nil
  end
  local action, ref = target:match('^([^@]+)@(.+)$')
  if not action then return nil end
  local owner, repo, path = action:match('^([%w%-_%.]+)/([%w%-_%.]+)(.*)$')
  if not owner then return nil end
  return {
    head = head,
    repo = owner .. '/' .. repo,
    path = path,
    ref = ref,
    comment = rest:match('#%s*(.-)%s*$'),
  }
end

--- Whether `ref` is a full commit
---@param ref string
---@return boolean
function M.pinned(ref) return ref:match('^%x+$') ~= nil and #ref == 40 end

--- `uses` pinned to `sha`, its old ref in the comment
---@param uses DyActionsUses
---@param sha string
---@return string
function M.pin_line(uses, sha)
  -- A comment of the author's own stays after the ref
  local comment = uses.ref
  if uses.comment and uses.comment ~= '' and uses.comment ~= uses.ref then
    comment = comment .. ' ' .. uses.comment
  end
  return ('%s%s%s@%s # %s'):format(
    uses.head,
    uses.repo,
    uses.path,
    sha,
    comment
  )
end

--- Pin every action of the workflow of `bufnr`
---@param bufnr? integer
function M.pin(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf()
    or bufnr
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  ---@type table<string, integer[]> Rows of each `repo@ref` to pin
  local todo, order = {}, {}
  for row, line in ipairs(lines) do
    local uses = M.parse(line)
    if uses and not M.pinned(uses.ref) then
      local key = uses.repo .. '@' .. uses.ref
      if not todo[key] then
        todo[key] = {}
        table.insert(order, key)
      end
      table.insert(todo[key], row)
    end
  end
  if #order == 0 then return notify('Every action is pinned already') end
  if vim.fn.executable('gh') ~= 1 then
    return notify('gh is not installed', vim.log.levels.ERROR)
  end

  local tick = vim.api.nvim_buf_get_changedtick(bufnr)
  local shas, failed, pending = {}, {}, #order
  local github = { kind = 'github', host = 'github.com', name = 'github' }
  for _, key in ipairs(order) do
    local repo, ref = key:match('^(.-)@(.+)$')
    forge.api(
      vim.tbl_extend('force', github, { slug = repo }),
      ('repos/%s/commits/%s'):format(repo, forge.encode(ref)),
      function(data, err)
        if
          type(data) == 'table'
          and type(data.sha) == 'string'
          and M.pinned(data.sha)
        then
          shas[key] = data.sha
        else
          table.insert(failed, ('%s: %s'):format(key, err or 'no commit'))
        end
        pending = pending - 1
        if pending > 0 then return end
        if not vim.api.nvim_buf_is_valid(bufnr) then return end
        -- Edited meanwhile: the rows may point elsewhere now
        if vim.api.nvim_buf_get_changedtick(bufnr) ~= tick then
          return notify(
            'The workflow changed meanwhile: nothing pinned',
            vim.log.levels.WARN
          )
        end
        local count = 0
        for found, rows in pairs(todo) do
          if shas[found] then
            for _, row in ipairs(rows) do
              local line =
                vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
              local uses = M.parse(line)
              vim.api.nvim_buf_set_lines(
                bufnr,
                row - 1,
                row,
                false,
                { M.pin_line(uses, shas[found]) }
              )
              count = count + 1
            end
          end
        end
        table.sort(failed)
        notify(
          ('%d uses pinned'):format(count)
            .. (
              #failed > 0 and ('; not found:\n' .. table.concat(failed, '\n'))
              or ''
            ),
          #failed > 0 and vim.log.levels.WARN or nil
        )
      end
    )
  end
end

--- The mappings of a workflow
---@param bufnr integer
function M.attach(bufnr)
  vim.keymap.set(
    'n',
    '<localleader>P',
    function() M.pin(bufnr) end,
    { buffer = bufnr, desc = 'Pin Actions To Commits (CI)' }
  )
end

return M
