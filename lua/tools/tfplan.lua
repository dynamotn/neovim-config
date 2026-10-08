--- A Terraform or OpenTofu plan, shown on the blocks it changes
---
--- `plan` prints what it would do as a long list of addresses, far from the
--- code that asks for it. Here the same plan lands on the `resource`, `data`
--- and `module` blocks of the module being edited, as diagnostics: what is
--- created, changed, replaced and why, and destroyed, each on its own line,
--- with `]d` to walk them and the quickfix list holding all of it.
---
--- The plan is saved to a private temporary file only to be read back with
--- `show -json`, then deleted: a plan file holds every value it planned,
--- secrets included, in plain text.
local M = {}

local ns = vim.api.nvim_create_namespace('dy_tfplan')

--- Milliseconds a plan may run before it is stopped
M.TIMEOUT = 15 * 60 * 1000

---@alias DyTfAction 'create'|'update'|'replace'|'destroy'|'read'

---@class DyTfChange
---@field action DyTfAction
---@field address string
---@field mode 'managed'|'data'
---@field type string
---@field name string
---@field module? string The first `module.<name>` of its address, if any
---@field forces string[] Attributes that force a replacement

--- The action of a `change.actions` list
---@param actions string[]
---@return DyTfAction?
local function action_of(actions)
  local joined = table.concat(actions or {}, ',')
  if joined == 'create' then return 'create' end
  if joined == 'update' then return 'update' end
  if joined == 'delete' then return 'destroy' end
  if joined == 'read' then return 'read' end
  if joined == 'delete,create' or joined == 'create,delete' then
    return 'replace'
  end
  return nil
end

--- A `replace_paths` entry as an attribute path: `tags.Name`, `ingress[0]`
---@param path (string|integer)[]
---@return string
local function path_string(path)
  local out = ''
  for _, step in ipairs(path) do
    if type(step) == 'number' then
      out = out .. ('[%d]'):format(step)
    else
      out = out == '' and tostring(step) or out .. '.' .. tostring(step)
    end
  end
  return out
end

--- The changes of a plan, from the output of `show -json`
---@param plan table
---@return DyTfChange[]
function M.changes(plan)
  local changes = {}
  for _, rc in ipairs(plan.resource_changes or {}) do
    local action = action_of(vim.tbl_get(rc, 'change', 'actions'))
    if action then
      local forces = {}
      for _, path in ipairs(vim.tbl_get(rc, 'change', 'replace_paths') or {}) do
        table.insert(forces, path_string(path))
      end
      table.insert(changes, {
        action = action,
        address = rc.address,
        mode = rc.mode,
        type = rc.type,
        name = rc.name,
        module = rc.module_address
          and rc.module_address:match('^module%.([^.%[]+)'),
        forces = forces,
      })
    end
  end
  return changes
end

--- Where each block of the `.tf` files of `dir` starts, by what it declares:
--- `resource.aws_s3_bucket.logs`, `data.aws_iam_policy.read`, `module.vpc`
---@param dir string
---@return table<string, { file: string, line: integer }>
function M.index(dir)
  local blocks = {}
  for name, kind in vim.fs.dir(dir) do
    if kind == 'file' and (name:match('%.tf$') or name:match('%.tofu$')) then
      local file = vim.fs.joinpath(dir, name)
      local ok, lines = pcall(vim.fn.readfile, file)
      for number, line in ipairs(ok and lines or {}) do
        local block, first, second =
          line:match('^%s*(%a+)%s+"([^"]+)"%s*"?([^"%s{]*)"?%s*{')
        if block == 'resource' or block == 'data' then
          blocks[block .. '.' .. first .. '.' .. second] =
            { file = file, line = number }
        elseif block == 'module' then
          blocks['module.' .. first] = { file = file, line = number }
        end
      end
    end
  end
  return blocks
end

--- What each action is called, how it is marked and how loud it is
local ACTIONS = {
  create = {
    sign = '+',
    word = 'create',
    severity = vim.diagnostic.severity.HINT,
  },
  read = { sign = '<=', word = 'read', severity = vim.diagnostic.severity.HINT },
  update = {
    sign = '~',
    word = 'update in place',
    severity = vim.diagnostic.severity.INFO,
  },
  replace = {
    sign = '-/+',
    word = 'replace',
    severity = vim.diagnostic.severity.WARN,
  },
  destroy = {
    sign = '-',
    word = 'destroy',
    severity = vim.diagnostic.severity.WARN,
  },
}

--- The order the actions of one block are listed in, loudest first
local ORDER = { 'destroy', 'replace', 'update', 'create', 'read' }

---@class DyTfEntry
---@field file? string
---@field line? integer
---@field text string
---@field severity integer

--- One entry per block the plan touches, and one for each change whose block
--- is not in `blocks` -- one of a nested module, or of a file not read
---@param changes DyTfChange[]
---@param blocks table<string, { file: string, line: integer }>
---@return DyTfEntry[]
function M.entries(changes, blocks)
  ---@type table<string, { where: table?, label: string, counts: table, forces: table }>
  local groups, order = {}, {}
  for _, change in ipairs(changes) do
    local key = change.module and ('module.' .. change.module)
      or (
        (change.mode == 'data' and 'data' or 'resource')
        .. '.'
        .. change.type
        .. '.'
        .. change.name
      )
    local group = groups[key]
    if not group then
      group = {
        where = blocks[key],
        label = change.module and key or change.address:gsub('%[.*%]$', ''),
        counts = {},
        forces = {},
      }
      groups[key] = group
      table.insert(order, key)
    end
    group.counts[change.action] = (group.counts[change.action] or 0) + 1
    for _, force in ipairs(change.forces) do
      if not vim.list_contains(group.forces, force) then
        table.insert(group.forces, force)
      end
    end
  end

  local entries = {}
  for _, key in ipairs(order) do
    local group = groups[key]
    local parts, severity = {}, vim.diagnostic.severity.HINT
    for _, action in ipairs(ORDER) do
      local count = group.counts[action]
      if count then
        local info = ACTIONS[action]
        table.insert(
          parts,
          ('%s %s%s'):format(
            info.sign,
            info.word,
            count > 1 and (' ×' .. count) or ''
          )
        )
        severity = math.min(severity, info.severity)
      end
    end
    local text = table.concat(parts, ', ')
    if #group.forces > 0 then
      text = text .. ' (forced by ' .. table.concat(group.forces, ', ') .. ')'
    end
    if not group.where then text = group.label .. ': ' .. text end
    table.insert(entries, {
      file = group.where and group.where.file,
      line = group.where and group.where.line,
      text = text,
      severity = severity,
    })
  end
  return entries
end

--- The one-line summary `plan` itself ends with
---@param changes DyTfChange[]
---@return string
function M.summary(changes)
  local counts = { create = 0, update = 0, destroy = 0, replace = 0 }
  for _, change in ipairs(changes) do
    if counts[change.action] then
      counts[change.action] = counts[change.action] + 1
    end
  end
  if counts.create + counts.update + counts.destroy + counts.replace == 0 then
    return 'No changes'
  end
  return ('Plan: %d to add, %d to change, %d to destroy, %d to replace'):format(
    counts.create,
    counts.update,
    counts.destroy,
    counts.replace
  )
end

--- Forget the plan shown, in every buffer
function M.clear()
  vim.diagnostic.reset(ns)
  local qf = vim.fn.getqflist({ title = 0 })
  if qf.title and qf.title:find('^Terraform plan') then
    vim.fn.setqflist({}, 'r')
  end
end

--- Show `entries` as diagnostics of their files and in the quickfix list
---@param entries DyTfEntry[]
---@param title string
function M.show(entries, title)
  vim.diagnostic.reset(ns)
  ---@type table<integer, vim.Diagnostic[]>
  local per_buffer = {}
  local items = {}
  for _, entry in ipairs(entries) do
    if entry.file then
      local bufnr = vim.fn.bufadd(entry.file)
      per_buffer[bufnr] = per_buffer[bufnr] or {}
      table.insert(per_buffer[bufnr], {
        lnum = entry.line - 1,
        col = 0,
        message = entry.text,
        severity = entry.severity,
        source = 'plan',
      })
    end
    table.insert(items, {
      filename = entry.file,
      lnum = entry.line or 0,
      text = entry.text,
      type = entry.severity == vim.diagnostic.severity.WARN and 'W' or 'I',
    })
  end
  for bufnr, diagnostics in pairs(per_buffer) do
    vim.diagnostic.set(ns, bufnr, diagnostics)
  end
  vim.fn.setqflist({}, ' ', { title = title, items = items })
end

---@param msg string
---@param level? integer
local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'Terraform plan' })
end

--- The binary to plan with: OpenTofu when it is there
---@return string?
function M.binary()
  for _, name in ipairs({ 'tofu', 'terraform' }) do
    if vim.fn.executable(name) == 1 then return name end
  end
end

--- Plan the module of the current buffer, and show the plan on its blocks
function M.plan()
  local bin = M.binary()
  if not bin then
    return notify(
      'Neither tofu nor terraform is installed',
      vim.log.levels.ERROR
    )
  end
  local name = vim.api.nvim_buf_get_name(0)
  local dir = name ~= '' and vim.fs.dirname(name) or vim.uv.cwd() --[[@as string]]
  local planfile = vim.fn.tempname()
  notify(('Planning %s with %s…'):format(vim.fn.fnamemodify(dir, ':~'), bin))

  local function cleanup() vim.fn.delete(planfile) end
  local function failed(what, result)
    cleanup()
    local err = vim.trim(result.stderr or '')
    if err == '' then err = vim.trim(result.stdout or '') end
    notify(what .. ' failed:\n' .. err, vim.log.levels.ERROR)
  end

  vim.system({
    bin,
    'plan',
    '-input=false',
    '-lock=false',
    '-no-color',
    '-out=' .. planfile,
  }, { cwd = dir, text = true, timeout = M.TIMEOUT }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then return failed('plan', result) end
      vim.system(
        { bin, 'show', '-json', planfile },
        { cwd = dir, text = true },
        function(show)
          vim.schedule(function()
            if show.code ~= 0 then return failed('show', show) end
            cleanup()
            local ok, plan = pcall(vim.json.decode, show.stdout or '')
            if not ok or type(plan) ~= 'table' then
              return notify(
                'show -json printed something that is not JSON',
                vim.log.levels.ERROR
              )
            end
            local changes = M.changes(plan)
            local summary = M.summary(changes)
            M.show(
              M.entries(changes, M.index(dir)),
              'Terraform plan: ' .. summary
            )
            notify(summary)
          end)
        end
      )
    end)
  end)
end

--- `:TfPlan [clear]`
---@param args { fargs: string[] }
function M.command(args)
  if args.fargs[1] == 'clear' then return M.clear() end
  if args.fargs[1] then
    return notify('Unknown subcommand: ' .. args.fargs[1], vim.log.levels.ERROR)
  end
  M.plan()
end

--- The mappings of a Terraform buffer
---@param bufnr integer
function M.attach(bufnr)
  vim.keymap.set(
    'n',
    '<localleader>p',
    M.plan,
    { buffer = bufnr, desc = 'Plan (Terraform)' }
  )
  vim.keymap.set(
    'n',
    '<localleader>P',
    M.clear,
    { buffer = bufnr, desc = 'Clear Plan (Terraform)' }
  )
end

return M
