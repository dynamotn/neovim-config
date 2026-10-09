--- Prompts `:DyAi` sends: Markdown files, shipped in `prompts/` of this
--- configuration and added to by a project in `.nvim/prompts/`
---
--- A project's folder is read only while `util.project_rtp` has it on the
--- runtimepath, that is once `vim.secure.read` has trusted it: the text of a
--- prompt goes to an AI with the user's code, so a repository does not get to
--- write it unasked.
local M = {}

---@class DyAiPrompt
---@field name string File name without `.md`, what `:DyAi <name>` takes
---@field description string
---@field body string
---@field path string
---@field project boolean Whether it comes from the project's `.nvim` folder

---@class DyAiContext
---@field bufnr integer Buffer the prompt is about
---@field range? integer[] First and last line, 1-based, of the selection
---@field input? string What the user answered to `{input}`

--- Bytes of a buffer's text a prompt may carry
M.MAX_BYTES = 256 * 1024

--- Folder of the prompts this configuration ships
M.BUILTIN = vim.fs.normalize(
  vim.fs.joinpath(
    vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2)),
    '../../../prompts'
  )
)

--- Read one prompt file. A `description:` line in front matter names it in
--- the picker; without one, its first line of text does.
---@param path string
---@param project boolean
---@return DyAiPrompt?
function M.read(path, project)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then return nil end
  local description
  if lines[1] == '---' then
    for i = 2, #lines do
      if lines[i] == '---' then
        lines = vim.list_slice(lines, i + 1)
        break
      end
      description = description or lines[i]:match('^description:%s*(.-)%s*$')
    end
  end
  while lines[1] == '' do
    table.remove(lines, 1)
  end
  if #lines == 0 then return nil end
  return {
    name = vim.fn.fnamemodify(path, ':t:r'),
    description = description or lines[1]:gsub('^#+%s*', ''),
    body = table.concat(lines, '\n'),
    path = path,
    project = project,
  }
end

--- Every prompt, by name. A project's prompt replaces a shipped one of the
--- same name.
---@return DyAiPrompt[]
function M.list()
  local by_name = {}
  local folders = { { M.BUILTIN, false } }
  local project = require('util.project_rtp').current()
  if project then table.insert(folders, { project .. '/prompts', true }) end
  for _, folder in ipairs(folders) do
    for _, path in ipairs(vim.fn.glob(folder[1] .. '/*.md', true, true)) do
      local prompt = M.read(path, folder[2])
      if prompt then by_name[prompt.name] = prompt end
    end
  end
  local prompts = vim.tbl_values(by_name)
  table.sort(prompts, function(a, b) return a.name < b.name end)
  return prompts
end

--- A prompt a command of `tools.ai` is built on, such as `git/commit.md`:
--- the trusted project's own, else the one shipped. These sit in folders, out
--- of the list of prompts to pick from.
---@param path string Relative to a `prompts/` folder
---@return DyAiPrompt?
function M.template(path)
  local project = require('util.project_rtp').current()
  if project then
    local own = M.read(project .. '/prompts/' .. path, true)
    if own then return own end
  end
  return M.read(M.BUILTIN .. '/' .. path, false)
end

---@param name string
---@return DyAiPrompt?
function M.get(name)
  for _, prompt in ipairs(M.list()) do
    if prompt.name == name then return prompt end
  end
end

--- A Markdown fence for `text`: longer than any run of backticks in it, so
--- code that holds fences of its own (Markdown, a README) stays inside
---@param text string
---@return string
function M.fence(text)
  local longest = 2
  for run in text:gmatch('`+') do
    longest = math.max(longest, #run)
  end
  return ('`'):rep(longest + 1)
end

--- Lines of the selection, or of the whole buffer, cut at `M.MAX_BYTES`
---@param ctx DyAiContext
---@return string text
---@return boolean cut
local function code(ctx)
  local first, last = 0, -1
  if ctx.range then
    first, last = ctx.range[1] - 1, ctx.range[2]
  end
  local text = table.concat(
    vim.api.nvim_buf_get_lines(ctx.bufnr, first, last, false),
    '\n'
  )
  if #text <= M.MAX_BYTES then return text, false end
  -- Never in the middle of a character: back to the start of the one the
  -- cut falls in
  local last = M.MAX_BYTES + vim.str_utf_start(text, M.MAX_BYTES + 1)
  return text:sub(1, last), true
end

--- Diagnostics of the selection, or of the whole buffer, one a line
---@param ctx DyAiContext
---@return string
local function diagnostics(ctx)
  local lines = {}
  for _, d in ipairs(vim.diagnostic.get(ctx.bufnr)) do
    local line = d.lnum + 1
    if not ctx.range or (line >= ctx.range[1] and line <= ctx.range[2]) then
      table.insert(
        lines,
        ('- line %d, %s%s: %s'):format(
          line,
          vim.diagnostic.severity[d.severity]:lower(),
          d.source and (' (' .. d.source .. ')') or '',
          d.message
        )
      )
    end
  end
  return #lines > 0 and table.concat(lines, '\n') or '(no diagnostics)'
end

--- Whether `prompt` asks the user for something first
---@param prompt DyAiPrompt
---@return boolean
function M.wants_input(prompt)
  return prompt.body:find('{input}', 1, true) ~= nil
end

--- Fill the placeholders of `prompt` from `ctx`: `{selection}` (fenced, the
--- selection or the whole buffer), `{file}`, `{filetype}`, `{diagnostics}`
--- and `{input}`. Any other `{word}` is left as it is.
---@param prompt DyAiPrompt
---@param ctx DyAiContext
---@return string text
---@return boolean cut Whether the code was cut at `M.MAX_BYTES`
function M.expand(prompt, ctx)
  local cut = false
  local values = {
    file = function()
      local name = vim.api.nvim_buf_get_name(ctx.bufnr)
      return name ~= '' and vim.fn.fnamemodify(name, ':~:.') or '[No Name]'
    end,
    filetype = function() return vim.bo[ctx.bufnr].filetype end,
    selection = function()
      local text
      text, cut = code(ctx)
      local where = ctx.range
          and (' (lines %d-%d)'):format(ctx.range[1], ctx.range[2])
        or ''
      local fence = M.fence(text)
      return ('%s%s%s\n%s\n%s%s'):format(
        fence,
        vim.bo[ctx.bufnr].filetype,
        where,
        text,
        fence,
        cut and ('\n(cut at %d KiB)'):format(M.MAX_BYTES / 1024) or ''
      )
    end,
    diagnostics = function() return diagnostics(ctx) end,
    input = function() return ctx.input or '' end,
  }
  local text = prompt.body:gsub(
    '{(%a+)}',
    function(key) return values[key] and values[key]() or nil end
  )
  return text, cut
end

return M
