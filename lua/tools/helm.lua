--- A Helm chart's values and the templates that use them, one key away
---
--- A template says `.Values.image.tag`; the value lives in `values.yaml` of
--- the chart, many files away. In a template, `<localleader>v` (`:DyHelmValue`)
--- goes to the line of the value under the cursor. In `values.yaml`,
--- `<localleader>u` (`:DyHelmUsages`) lists every template line using the key
--- under the cursor, and `:DyHelmUnused` marks the keys no template uses.
---
--- A key counts as used when a template names it, a parent of it -- `toYaml
--- .Values.resources` uses all of `resources` -- or a child. `global` and
--- the values of a subchart are its own business, and left out.
local M = {}

local ns = vim.api.nvim_create_namespace('dy_helm')

local notify = require('util.notify').titled('Helm')

--- Every `.Values.a.b` path of `text`, `$.Values` included, as dotted strings
---@param text string
---@return { path: string, col: integer }[] With the 1-based column it starts
function M.references(text)
  local found = {}
  for col, path in text:gmatch('()%$?%.Values%.([%w_%.]+)') do
    path = path:gsub('%.$', '')
    if path ~= '' then table.insert(found, { path = path, col = col }) end
  end
  return found
end

--- The `.Values` path under byte `col` (1-based) of `line`
---@param line string
---@param col integer
---@return string?
function M.path_at(line, col)
  for _, ref in ipairs(M.references(line)) do
    local stop = ref.col
      + #('.Values.' .. ref.path)
      + (line:sub(ref.col, ref.col) == '$' and 1 or 0)
    if col >= ref.col and col < stop then return ref.path end
  end
  return nil
end

--- Where each key of a values file is, as a dotted path: the keys of
--- mappings only -- a list item and a block scalar (`|`, `>`) hold none
---@param lines string[]
---@return table<string, integer> Path to its 1-based line
---@return string[] paths In the order of the file
function M.paths(lines)
  local paths, order, stack = {}, {}, {}
  local skip_deeper -- Indent below which lines belong to a list or a scalar
  for number, line in ipairs(lines) do
    local indent = #line:match('^(%s*)')
    local content = line:sub(indent + 1)
    if content == '' or content:match('^#') then goto continue end
    if skip_deeper and indent > skip_deeper then goto continue end
    skip_deeper = nil
    if content:match('^%-') then
      -- A list: nothing in it is a key of its own
      skip_deeper = indent
      goto continue
    end
    local key, rest = content:match('^["\']?([^"\'%s:#]+)["\']?%s*:%s*(.*)$')
    if key then
      while #stack > 0 and stack[#stack].indent >= indent do
        table.remove(stack)
      end
      table.insert(stack, { indent = indent, key = key })
      local path = table.concat(
        vim.tbl_map(function(item) return item.key end, stack),
        '.'
      )
      if not paths[path] then
        paths[path] = number
        table.insert(order, path)
      end
      if rest:match('^[|>]') then skip_deeper = indent end
    end
    ::continue::
  end
  return paths, order
end

--- The path of the key on 1-based `row` of a values file
---@param lines string[]
---@param row integer
---@return string?
function M.path_of_row(lines, row)
  local paths = M.paths(lines)
  local best
  for path, line in pairs(paths) do
    if line == row then best = path end
  end
  return best
end

--- Whether `path` is used by any of `refs`: itself, a parent or a child
---@param path string
---@param refs table<string, true>
---@return boolean
function M.used(path, refs)
  if refs[path] then return true end
  for ref in pairs(refs) do
    if vim.startswith(path, ref .. '.') or vim.startswith(ref, path .. '.') then
      return true
    end
  end
  return false
end

--- The root of the chart `file` belongs to
---@param file string
---@return string?
function M.root(file)
  if file == '' then return nil end
  local found =
    vim.fs.find('Chart.yaml', { upward = true, path = vim.fs.dirname(file) })[1]
  return found and vim.fs.dirname(found) or nil
end

--- The templates of the chart at `root`
---@param root string
---@return string[]
local function templates(root)
  return vim.fs.find(
    function(name)
      return name:match('%.ya?ml$')
        or name:match('%.tpl$')
        or name:match('%.txt$')
    end,
    {
      path = vim.fs.joinpath(root, 'templates'),
      type = 'file',
      limit = math.huge,
    }
  )
end

--- The names of the subcharts of the chart at `root`, whose values are
--- theirs to use
---@param root string
---@return table<string, true>
function M.subcharts(root)
  local names = { global = true }
  for name, kind in vim.fs.dir(vim.fs.joinpath(root, 'charts')) do
    if kind == 'directory' then names[name] = true end
    local tarball = name:match('^(.-)%-%d[^/]*%.tgz$')
    if tarball then names[tarball] = true end
  end
  local ok, lines = pcall(vim.fn.readfile, vim.fs.joinpath(root, 'Chart.yaml'))
  for _, line in ipairs(ok and lines or {}) do
    local name = line:match('^%s*%-?%s*name:%s*["\']?([%w_%-]+)')
    local alias = line:match('^%s*alias:%s*["\']?([%w_%-]+)')
    if alias then names[alias] = true end
    -- `name:` at the top is the chart itself; under `dependencies:` it is not
    if name and line:match('^%s+') then names[name] = true end
  end
  return names
end

--- Go from the `.Values` path under the cursor to its line in values.yaml
function M.value()
  local file = vim.api.nvim_buf_get_name(0)
  local root = M.root(file)
  if not root then return notify('Not in a Helm chart', vim.log.levels.WARN) end
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local path = M.path_at(vim.api.nvim_get_current_line(), col)
  if not path then
    return notify('No .Values under the cursor', vim.log.levels.WARN)
  end
  local values = vim.fs.joinpath(root, 'values.yaml')
  if vim.fn.filereadable(values) ~= 1 then
    return notify('The chart has no values.yaml', vim.log.levels.WARN)
  end
  local paths = M.paths(vim.fn.readfile(values))
  -- The deepest key of the path that the file sets
  local parts = vim.split(path, '.', { plain = true })
  for count = #parts, 1, -1 do
    local line = paths[table.concat(parts, '.', 1, count)]
    if line then
      vim.cmd.edit(vim.fn.fnameescape(values))
      vim.api.nvim_win_set_cursor(0, { line, 0 })
      if count < #parts then
        notify(
          ('values.yaml sets %s, not %s'):format(
            table.concat(parts, '.', 1, count),
            path
          )
        )
      end
      return
    end
  end
  notify(('values.yaml does not set %s'):format(path), vim.log.levels.WARN)
end

--- Every template line using `path`, itself, a parent or a child
---@param root string
---@param path string
---@return table[] Quickfix items
function M.usages(root, path)
  local items = {}
  for _, file in ipairs(templates(root)) do
    local ok, lines = pcall(vim.fn.readfile, file)
    for number, line in ipairs(ok and lines or {}) do
      for _, ref in ipairs(M.references(line)) do
        if M.used(path, { [ref.path] = true }) then
          table.insert(items, {
            filename = file,
            lnum = number,
            col = ref.col,
            text = vim.trim(line),
          })
          break
        end
      end
    end
  end
  return items
end

--- List the template lines using the key under the cursor of values.yaml
function M.show_usages()
  local file = vim.api.nvim_buf_get_name(0)
  local root = M.root(file)
  if not root then return notify('Not in a Helm chart', vim.log.levels.WARN) end
  local path = M.path_of_row(
    vim.api.nvim_buf_get_lines(0, 0, -1, false),
    vim.api.nvim_win_get_cursor(0)[1]
  )
  if not path then return notify('No key on this line', vim.log.levels.WARN) end
  local items = M.usages(root, path)
  if #items == 0 then return notify(('No template uses %s'):format(path)) end
  vim.fn.setqflist({}, ' ', { title = 'Helm: ' .. path, items = items })
  vim.cmd('copen')
end

--- Mark the keys of the values buffer that no template uses
---@param bufnr? integer
function M.unused(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf()
    or bufnr
  local root = M.root(vim.api.nvim_buf_get_name(bufnr))
  if not root then return notify('Not in a Helm chart', vim.log.levels.WARN) end
  local refs = {}
  for _, file in ipairs(templates(root)) do
    local ok, lines = pcall(vim.fn.readfile, file)
    for _, ref in ipairs(M.references(table.concat(ok and lines or {}, '\n'))) do
      refs[ref.path] = true
    end
  end
  local skip = M.subcharts(root)
  local paths, order = M.paths(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  local diagnostics = {}
  for _, path in ipairs(order) do
    local top = path:match('^[^.]+')
    if not skip[top] and not M.used(path, refs) then
      -- A parent unused says it for its children
      local parent = path:match('^(.*)%.[^.]+$')
      if not (parent and paths[parent] and not M.used(parent, refs)) then
        table.insert(diagnostics, {
          lnum = paths[path] - 1,
          col = 0,
          severity = vim.diagnostic.severity.HINT,
          message = ('No template uses %s'):format(path),
          source = 'helm',
        })
      end
    end
  end
  vim.diagnostic.set(ns, bufnr, diagnostics)
  notify(('%d values no template uses'):format(#diagnostics))
end

--- The mappings of a chart's template or values buffer
---@param bufnr integer
function M.attach(bufnr)
  if not M.root(vim.api.nvim_buf_get_name(bufnr)) then return end
  if vim.bo[bufnr].filetype == 'helm' then
    vim.keymap.set(
      'n',
      '<localleader>v',
      M.value,
      { buffer = bufnr, desc = 'Go To Value (Helm)' }
    )
  else
    vim.keymap.set(
      'n',
      '<localleader>u',
      M.show_usages,
      { buffer = bufnr, desc = 'Template Usages (Helm)' }
    )
    vim.keymap.set(
      'n',
      '<localleader>U',
      function() M.unused(bufnr) end,
      { buffer = bufnr, desc = 'Unused Values (Helm)' }
    )
  end
end

return M
