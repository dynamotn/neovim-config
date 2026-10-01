-- Open a file of every language in the configuration `check-startup.sh` has
-- just loaded, and report every error that surfaces on the way.
--
-- Starting an empty Neovim only reaches `init.lua`: the `FileType`
-- dispatcher, the language servers, linters and formatters, and every plugin
-- that loads on a buffer event are left alone. Opening real files runs them.
--
-- A few things stand in the way of seeing what goes wrong, and are dealt with
-- here:
--
-- - Headless, the notifier has no UI to draw on and drops what it is sent, so
--   an error a handler reports through `vim.notify` never reaches the output.
--   Errors are copied to stderr, where the shell script looks for them.
-- - Opening a file installs whatever its language is missing. A check must
--   not download tools behind the user's back, so installs are recorded and
--   skipped instead -- and the names they were asked for are checked, since a
--   name nothing can install is the one mistake the real install would find.
-- - Headless there is nobody to answer a prompt, so prompts are cancelled.
-- - `config.languages` covers about a hundred languages, and a fixture file
--   for each would be a hundred files to keep in step with it. A tiny file per
--   filetype is written to a scratch directory instead, named so that
--   `vim.filetype.match` gives it that filetype.
--
-- `CHECK_STARTUP_ALL=1` opens every filetype of every language; without it
-- only one file each of a spread of languages is, so the pre-commit hook
-- stays quick. `CHECK_STARTUP_WORKDIR` is where the generated files go, and
-- `CHECK_STARTUP_TRACE=1` names each file on stderr as it is opened, to find
-- the one a hang is stuck on.

local sweep_all = vim.env.CHECK_STARTUP_ALL == '1'

-- Files of this repository itself, one per filetype. They hold real content,
-- which the empty generated files do not, so they stay even in the full sweep.
local repo_samples = {
  'init.lua',
  'scripts/check-startup.sh',
  '.pre-commit-config.yaml',
  'README.md',
  'renovate.json',
  '.stylua.toml',
}

-- Languages the quick run opens on top of the repository files: one of each
-- kind of wiring (servers with an `enabled` check, compound filetypes, files
-- told apart by path or by name, tools that are not from Mason).
local quick_languages = {
  'ansible',
  'bash',
  'dockerfile',
  'go',
  'helm',
  'javascript',
  'make',
  'python',
  'rust',
  'terraform',
  'typescript',
}

-- File names for the filetypes that no `sample.<filetype>` maps to: they are
-- known by their whole name, by the directory they sit in, or by an extension
-- named after something else. Paths are relative to the scratch directory.
---@type table<string, string>
local names_of = {
  arduino = 'sample.ino',
  automake = 'Makefile.am',
  blade = 'sample.blade.php',
  cmake = 'CMakeLists.txt',
  config = 'configure.ac',
  cucumber = 'sample.feature',
  dockerfile = 'Dockerfile',
  dosini = 'sample.ini',
  gitcommit = 'COMMIT_EDITMSG',
  gitrebase = 'git-rebase-todo',
  gomod = 'go.mod',
  gosum = 'go.sum',
  gowork = 'go.work',
  helm = 'chart/templates/sample.yaml',
  htmlangular = 'sample.component.html',
  htmldjango = 'templates/sample.html',
  hyprlang = 'hypr/sample.conf',
  javascriptreact = 'sample.jsx',
  ['json.openapi'] = 'openapi.json',
  just = 'justfile',
  make = 'Makefile',
  nginx = 'nginx.conf',
  query = 'queries/lua/highlights.scm',
  sh = 'sample.sh',
  ['sh.PKGBUILD'] = 'PKGBUILD',
  systemd = 'systemd/system/sample.service',
  ['terraform-vars'] = 'sample.tfvars',
  terragrunt = 'terragrunt.hcl',
  typescriptreact = 'sample.tsx',
  ['yaml.ansible'] = 'playbooks/sample.yml',
  ['yaml.az-pl'] = 'azure-pipelines.yml',
  ['yaml.docker-compose'] = 'docker-compose.yml',
  ['yaml.gh-action'] = '.github/workflows/sample.yml',
  ['yaml.gitlab'] = 'sample.gitlab-ci.yml',
  ['yaml.helm-values'] = 'values.yaml',
  ['yaml.openapi'] = 'openapi.yaml',
}

local errors = {} ---@type string[]
---@type { mason: string[], parser: string[], download: string[] }
local installs = { mason = {}, parser = {}, download = {} }

local function report(msg) table.insert(errors, tostring(msg)) end

-- Plugins swap `vim.notify` out as they load, so the wrapper is put back on
-- top after every file rather than installed once.
local function watch_notify()
  local current = vim.notify
  if rawequal(current, _G._dy_check_notify) then return end
  _G._dy_check_notify = function(msg, level, opts)
    if (level or vim.log.levels.INFO) >= vim.log.levels.ERROR then
      report(msg)
    end
    return current(msg, level, opts)
  end
  vim.notify = _G._dy_check_notify
end

--- Run `hook` right before `plugin` is configured, or now if it already is
---
--- The installers have to be stubbed before the plugin that owns them runs
--- its `config`: on a machine that has nothing installed yet -- CI -- that
--- `config` is itself what starts installing.
---@param plugin string
---@param hook fun()
local function before_config(plugin, hook)
  local spec = require('lazy.core.config').plugins[plugin]
  if not spec then return end
  if spec._.loaded then return hook() end
  local loader = require('lazy.core.loader')
  local config = loader.config
  loader.config = function(p, ...)
    if p.name == plugin then hook() end
    return config(p, ...)
  end
end

local function skip_installs()
  before_config('mason.nvim', function()
    -- The lazy installers of `plugins.*` all go through `MasonInstall`.
    -- Headless, the real one exits Neovim on a package it does not know.
    require('mason.api.command').MasonInstall = function(packages)
      vim.list_extend(installs.mason, packages)
    end
    -- LazyVim's `ensure_installed` and anything else that asks a package
    -- directly. The handle it hands back is only ever listened on.
    require('mason-core.package').install = function(self)
      table.insert(installs.mason, self.name)
      local handle = {}
      function handle.on() return handle end
      function handle.once() return handle end
      return handle
    end
  end)
  before_config('nvim-treesitter', function()
    local treesitter = require('nvim-treesitter')
    treesitter.install = function(parsers)
      vim.list_extend(
        installs.parser,
        type(parsers) == 'table' and parsers or {}
      )
      -- Callers chain `:await` onto the task `install` hands back. The
      -- callback is never run: it reloads the buffer with `:e!`, which fires
      -- `FileType` again, finds the parser still missing, and so on forever.
      return { await = function() end }
    end
    -- `build` only makes sure the tree-sitter CLI and a C compiler are there
    -- to compile parsers with, and installs the CLI through Mason if not. A
    -- check that compiles nothing does not need either.
    LazyVim.treesitter.build = function(cb) cb() end
  end)
  -- Fetches its own `tinymist` and `websocat` release binaries on setup.
  before_config('typst-preview.nvim', function()
    require('typst-preview.fetch').fetch = function(_, callback)
      table.insert(installs.download, 'typst-preview')
      if callback then callback() end
    end
  end)
  -- Clones its `kulala_http` grammar and builds it with the tree-sitter CLI
  -- on setup, which throws from a scheduled callback where there is no CLI.
  before_config('kulala.nvim', function()
    local parser = require('kulala.config.parser')
    parser.setup = function()
      if not parser.is_up_to_date() then
        table.insert(installs.download, 'kulala_http')
      end
    end
  end)
  -- Turns Copilot's status into notifications, and an account that is not
  -- signed in into an error. That is the state of the machine the check runs
  -- on, not of the configuration, and only shows when the server reports it
  -- before Neovim quits.
  before_config('sidekick.nvim', function()
    local status = require('sidekick.status')
    local on_status = status.on_status
    status.on_status = function(err, res, ctx)
      if res and res.message and res.message:find('not signed') then
        res = vim.deepcopy(res)
        res.message = nil
      end
      return on_status(err, res, ctx)
    end
  end)
end

--- Report the recorded installs no real install could carry out
local function check_installs()
  local ok, registry = pcall(require, 'mason-registry')
  -- Without a registry on disk every name would look unknown, so the Mason
  -- half is only checked where there is one to ask.
  if ok and #registry.get_all_package_names() > 0 then
    for _, name in ipairs(LazyVim.dedup(installs.mason)) do
      if not registry.has_package(name) then
        report(string.format('no Mason package `%s` to install', name))
      end
    end
  end
  if #installs.parser > 0 then
    -- What `nvim-treesitter.install` does before it looks a parser up: the
    -- parsers this configuration adds itself only exist after `TSUpdate`.
    package.loaded['nvim-treesitter.parsers'] = nil
    local parsers = require('nvim-treesitter.parsers')
    vim.api.nvim_exec_autocmds('User', { pattern = 'TSUpdate' })
    for _, name in ipairs(LazyVim.dedup(installs.parser)) do
      if not parsers[name] then
        report(string.format('no tree-sitter parser `%s` to install', name))
      end
    end
  end
end

--- Pick a file name that `vim.filetype.match` gives `filetype`
---@param filetype string
---@param name string Language the filetype belongs to
---@param language DyLangSpec
---@param root string
---@return string?
local function sample_of(filetype, name, language, root)
  local candidates = { 'sample.' .. filetype, 'sample.' .. name }
  if language.ext then
    table.insert(candidates, 1, 'sample.' .. language.ext)
  end
  if names_of[filetype] then table.insert(candidates, 1, names_of[filetype]) end
  for _, candidate in ipairs(candidates) do
    local path = vim.fs.joinpath(root, candidate)
    if vim.filetype.match({ filename = path }) == filetype then return path end
  end
end

--- Write a file per filetype into `root`, or per language outside of the
--- full sweep
---@param root string
---@return { path: string, filetype: string, language: string }[] samples
---@return string[] unmapped Filetypes no file name could be found for
---@return integer count Languages at least one file was written for
local function generate(root)
  local languages = require('config.languages')
  local names = sweep_all and vim.tbl_keys(languages) or quick_languages
  table.sort(names)
  local samples, unmapped, count = {}, {}, 0
  for _, name in ipairs(names) do
    -- `*` and `_` are what every buffer and a buffer of no language get,
    -- and the repository files above already stand for them.
    if name ~= '*' and name ~= '_' then
      local found = false
      for _, filetype in ipairs(languages[name].filetypes) do
        local path = sample_of(filetype, name, languages[name], root)
        if path then
          vim.fn.mkdir(vim.fs.dirname(path), 'p')
          vim.fn.writefile({ '' }, path)
          table.insert(
            samples,
            { path = path, filetype = filetype, language = name }
          )
          found = true
          if not sweep_all then break end
        elseif sweep_all then
          table.insert(unmapped, name .. '/' .. filetype)
        end
      end
      if found then
        count = count + 1
      elseif not sweep_all then
        table.insert(unmapped, name)
      end
    end
  end
  return samples, unmapped, count
end

local prompts = {} ---@type string[]

-- Headless there is nobody to answer a prompt, and one asked from a
-- `FileType` handler would hang the check: the prompt is recorded and
-- answered as if cancelled.
local function skip_prompts()
  local function cancel(prompt)
    table.insert(prompts, vim.trim(tostring(prompt)))
    return ''
  end
  vim.fn.input = function(opts)
    return cancel(type(opts) == 'table' and opts.prompt or opts)
  end
  vim.fn.inputsecret = cancel
  vim.ui.input = function(opts, on_confirm)
    cancel((opts or {}).prompt)
    on_confirm(nil)
  end
end

skip_installs()
skip_prompts()

local files = {} ---@type { path: string, filetype?: string, language?: string }[]
local config = vim.fn.stdpath('config') --[[@as string]]
for _, sample in ipairs(repo_samples) do
  table.insert(files, { path = vim.fs.joinpath(config, sample) })
end
local root = vim.env.CHECK_STARTUP_WORKDIR or vim.fn.tempname()
local generated, unmapped, count = generate(vim.fs.joinpath(root, 'samples'))
vim.list_extend(files, generated)

-- Handlers and language servers start from callbacks, not from the `:edit`
-- itself. A short wait per file lets most of them run next to the file that
-- set them off; the long one at the end catches the stragglers.
local wait = sweep_all and 30 or 100
for _, file in ipairs(files) do
  watch_notify()
  if vim.env.CHECK_STARTUP_TRACE then
    io.stderr:write('open ' .. file.path .. '\n')
  end
  local ok, err = pcall(vim.cmd.edit, vim.fn.fnameescape(file.path))
  if not ok then
    report(err)
  elseif file.filetype and vim.bo.filetype ~= file.filetype then
    -- `vim.filetype.match` and `:edit` disagree: the language was never
    -- really opened, so it would pass without having been checked.
    report(
      string.format(
        '%s: opened as `%s`, expected `%s`',
        file.language,
        vim.bo.filetype,
        file.filetype
      )
    )
  end
  vim.wait(wait)
end
watch_notify()
vim.wait(1000)
check_installs()

io.stdout:write(
  string.format(
    'check-startup: opened %d files (%d filetypes of %d languages%s)\n',
    #files,
    #generated,
    count,
    sweep_all and '' or ', CHECK_STARTUP_ALL=1 for all'
  )
)
if #unmapped > 0 then
  io.stdout:write(
    'check-startup: no file name for ' .. table.concat(unmapped, ', ') .. '\n'
  )
end
if #prompts > 0 then
  io.stdout:write(
    'check-startup: cancelled prompts '
      .. table.concat(LazyVim.dedup(prompts), ', ')
      .. '\n'
  )
end
for kind, names in pairs(installs) do
  if #names > 0 then
    io.stdout:write(
      string.format(
        'check-startup: skipped installing %s %s\n',
        kind,
        table.concat(LazyVim.dedup(names), ', ')
      )
    )
  end
end
--- Return the skipped package `msg` complains is missing, if it does
---
--- On a machine that has nothing installed -- CI -- a plugin that looks for
--- its tool as soon as the file opens finds it missing, because the install
--- that would have put it there was skipped by this check. That is the check
--- talking, not the configuration, so it is set apart rather than failed on.
--- Anything else about the same tool still fails.
---@param msg string
---@return string?
local function missing_skipped(msg)
  local lower = msg:lower()
  local missing = lower:find('not found')
    or lower:find('not executable')
    or lower:find('not installed')
    or lower:find('no such file')
  if not missing then return end
  for _, name in ipairs(installs.mason) do
    if msg:find(name, 1, true) then return name end
  end
end

local missing = {} ---@type string[]
for _, msg in ipairs(errors) do
  local name = missing_skipped(msg)
  if name then
    table.insert(missing, name)
  else
    io.stderr:write('Error: ' .. msg .. '\n')
  end
end
if #missing > 0 then
  io.stdout:write(
    'check-startup: missing because their install was skipped '
      .. table.concat(LazyVim.dedup(missing), ', ')
      .. '\n'
  )
end
vim.cmd('qa!')
