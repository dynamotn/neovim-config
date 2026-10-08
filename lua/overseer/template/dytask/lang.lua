---@module 'overseer'

--- Templates of the tasks in `config.tasks`, for the current file
local M = {}

--- Whether the search filetype, maybe compound (`sh.PKGBUILD`), is one of
--- `filetypes`
---@param filetypes string[]
---@param filetype string
---@return boolean
local function matches(filetypes, filetype)
  for _, ft in ipairs(vim.split(filetype, '.', { plain = true })) do
    if vim.list_contains(filetypes, ft) then return true end
  end
  return vim.list_contains(filetypes, filetype)
end

--- Filetypes as overseer's condition reads them: it splits the buffer's
--- filetype on `.` and looks for an entry among the parts, so a compound one
--- (`typescript.tsx`) never matches whole and is named by its last part
---@param filetypes string[]
---@return string[]
local function condition_filetypes(filetypes)
  local ret = {}
  for _, ft in ipairs(filetypes) do
    local part = ft:match('[^.]+$') or ft
    if not vim.list_contains(ret, part) then table.insert(ret, part) end
  end
  return ret
end

--- The first candidate that is executable
---@param exe string|string[]|fun(ctx: DyTaskContext): string?
---@param ctx DyTaskContext
---@return string?
local function resolve(exe, ctx)
  if type(exe) == 'function' then return exe(ctx) end
  local candidates = type(exe) == 'table' and exe or { exe } --[[@as string[] ]]
  for _, candidate in ipairs(candidates) do
    if vim.fn.executable(candidate) == 1 then return candidate end
  end
end

--- Turn a runner into a template, or nil when it does not apply to `file`
---@param lang string
---@param runner DyTaskRunner
---@param file string Absolute path of the current file
---@return overseer.TemplateDefinition?
M.to_template = function(lang, runner, file)
  ---@type DyTaskContext
  local ctx = {
    file = file,
    dir = vim.fs.dirname(file),
    stem = vim.fn.fnamemodify(file, ':r'),
    exe = '',
  }
  if runner.root then
    ctx.root = vim.fs.root(file, runner.root)
    if not ctx.root then return end
  end
  if runner.when and not runner.when(ctx) then return end
  local exe = resolve(runner.exe, ctx)
  if not exe then return end
  ctx.exe = exe

  ---@type overseer.TemplateDefinition
  return {
    name = runner.name,
    desc = runner.desc,
    builder = function()
      local components = { 'default' }
      if runner.build then
        table.insert(components, {
          'dependencies',
          tasks = {
            {
              cmd = runner.build(ctx),
              cwd = ctx.root or ctx.dir,
              -- A failed build never starts the run, whose output would
              -- otherwise be the only one shown: the compiler's errors are
              components = {
                'default',
                {
                  'open_output',
                  on_complete = 'failure',
                  direction = 'dock',
                  focus = true,
                },
              },
            },
          },
        })
      end
      table.insert(components, 'output')

      ---@type overseer.TaskDefinition
      return {
        cmd = runner.cmd(ctx),
        -- Where the file is, as when it is run by hand from there
        cwd = runner.cwd and runner.cwd(ctx) or ctx.root or ctx.dir,
        -- `default` sets the status from the exit code
        components = components,
      }
    end,
    condition = {
      filetype = condition_filetypes(
        runner.filetypes or require('config.languages')[lang].filetypes
      ),
    },
  }
end

--- Templates of the enabled languages for `file` of `filetype`
---@param file string
---@param filetype string
---@return overseer.TemplateDefinition[]
M.templates = function(file, filetype)
  local languages = require('config.languages')
  local ret = {}
  if file == '' or filetype == '' then return ret end
  for lang, runners in vim.spairs(require('config.tasks')) do
    if vim.list_contains(DyNeo.enabled_languages or {}, lang) then
      for _, runner in ipairs(runners) do
        if matches(runner.filetypes or languages[lang].filetypes, filetype) then
          local template = M.to_template(lang, runner, file)
          if template then table.insert(ret, template) end
        end
      end
    end
  end
  return ret
end

---@type overseer.TemplateFileProvider
return {
  generator = function(opts)
    local file = vim.api.nvim_buf_get_name(0)
    return M.templates(
      file ~= '' and vim.fn.fnamemodify(file, ':p') or '',
      opts.filetype or ''
    )
  end,
  -- For the specs
  to_template = M.to_template,
  templates = M.templates,
}
