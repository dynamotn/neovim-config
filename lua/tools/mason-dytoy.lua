--- A mason package type for the tools dytoy installs
---
--- Some tools have no mason package at all, or only one built differently
--- from what the rest of the machine runs: they come from the system package
--- manager, from mise, or from a script. `dytoy` already knows how to install
--- every one of them, so a package of this repository's registry can hand the
--- install over to it:
---
---   source = { id = 'dytoy:opentofu' },
---   bin = { tofu = 'tofu' },
---
--- The id names the tool as `dytoy --tool` knows it. mason reads every id as
--- a purl, so the registry index rewrites it to `pkg:dytoy/opentofu@latest`
--- as it loads the package (`M.normalize`). That version is only a label:
--- dytoy installs whatever its own definition names, so asking mason for
--- another version is refused rather than silently ignored.
---
--- The tool lands where dytoy puts it, outside mason's directory. Each `bin`
--- entry becomes a link at the path it names, inside the package, to the
--- command its key names wherever it was installed -- a mise shim rather than
--- a versioned mise directory, so an upgrade does not leave the link pointing
--- at a version that is gone. A tool whose commands are all there already is
--- only linked; dytoy is not run at all.
---
--- `sudo` has no terminal to ask on: mason runs dytoy with its output in a
--- pipe, behind the editor's screen. So dytoy finds a `sudo` first on `PATH`
--- that always asks through `SUDO_ASKPASS`, and the askpass helper calls back
--- into this Neovim, which asks with `inputsecret()`. The password goes from
--- that prompt to sudo through the helper's stdout and is kept nowhere; a
--- token known only to this install keeps any other process from opening the
--- prompt through the same call.
---
--- Uninstalling through mason removes the links only. What dytoy installed
--- stays on the machine, as it would after `dytoy` itself.
local M = {}

--- Installs in flight: the tool each askpass token was handed out for
---@type table<string, string>
M.pending = {}

--- Rewrite a `dytoy:<tool>` source id into the purl mason reads
---
--- The spec is changed in place: it is the table `require` keeps for the
--- package's module, so it is what mason gets when it requires that module in
--- turn. Any other id is left alone.
---@param spec RegistryPackageSpec
---@return RegistryPackageSpec
function M.normalize(spec)
  local id = vim.tbl_get(spec, 'source', 'id')
  local tool = type(id) == 'string' and id:match('^dytoy:([^/@]+)$')
  if tool then spec.source.id = ('pkg:dytoy/%s@latest'):format(tool) end
  return spec
end

--- Directory mise keeps its shims and installs in
---@return string
local function mise_data_dir()
  return vim.env.MISE_DATA_DIR
    or vim.fs.joinpath(
      vim.env.XDG_DATA_HOME or vim.fs.joinpath(vim.env.HOME, '.local', 'share'),
      'mise'
    )
end

---@param path string
---@return boolean
local function is_executable(path)
  local stat = vim.uv.fs_stat(path)
  return stat ~= nil
    and stat.type == 'file'
    and vim.uv.fs_access(path, 'X') == true
end

--- Where `command` runs from outside mason
---
--- `PATH` is searched first, without the directories in `skip` -- mason's own
--- `bin`, which holds the link this answer is for. A command found in a
--- versioned mise directory is swapped for its shim, which outlives an
--- upgrade. A mise tool `PATH` does not reach yet, because it was installed
--- after this Neovim started, is found through its shim as well.
---@param command string
---@param opts? { path?: string, skip?: string[], mise_dir?: string }
---@return string?
function M.resolve(command, opts)
  opts = opts or {}
  local skip = {}
  for _, dir in ipairs(opts.skip or {}) do
    skip[vim.fs.normalize(dir)] = true
  end
  local mise_dir = vim.fs.normalize(opts.mise_dir or mise_data_dir())
  local shim = vim.fs.joinpath(mise_dir, 'shims', command)
  local installs = vim.fs.joinpath(mise_dir, 'installs') .. '/'

  for dir in vim.gsplit(opts.path or vim.env.PATH or '', ':', { plain = true }) do
    if dir ~= '' and not skip[vim.fs.normalize(dir)] then
      local candidate = vim.fs.joinpath(dir, command)
      if is_executable(candidate) then
        if vim.startswith(vim.fs.normalize(dir) .. '/', installs) then
          return is_executable(shim) and shim or candidate
        end
        return candidate
      end
    end
  end
  return is_executable(shim) and shim or nil
end

--- The prompt the askpass helper calls back into
---
--- Answers only a token of an install still in flight. An empty answer -- the
--- prompt cancelled, or the token unknown -- makes the helper fail, so sudo
--- stops rather than trying an empty password.
---@param token string
---@return string
function M.askpass(token)
  local tool = M.pending[token]
  if not tool then return '' end
  local ok, password = pcall(
    vim.fn.inputsecret,
    ('[sudo] password for dytoy to install %s: '):format(tool)
  )
  vim.cmd.redraw()
  return ok and password or ''
end

---@param path string
---@param lines string[]
local function write_script(path, lines)
  vim.fn.writefile(vim.list_extend({ '#!/bin/sh' }, lines), path)
  vim.uv.fs_chmod(path, tonumber('700', 8))
end

--- Write the `sudo` that asks through Neovim, and its askpass helper
---
--- `-A` is left out when the caller reads the password from stdin itself, the
--- one mode sudo refuses to combine with it.
---@param dir string Directory to write both into
---@param opts { sudo: string, nvim: string, server: string, token: string }
---@return string askpass Path of the askpass helper
function M.write_helpers(dir, opts)
  local q = vim.fn.shellescape
  local askpass = vim.fs.joinpath(dir, 'askpass')
  local expr = ("v:lua.require'tools.mason-dytoy'.askpass('%s')"):format(
    opts.token
  )
  write_script(askpass, {
    ('password=$(%s --clean --headless --server %s --remote-expr %s) || exit 1'):format(
      q(opts.nvim),
      q(opts.server),
      q(expr)
    ),
    '[ -n "$password" ] || exit 1',
    'printf \'%s\\n\' "$password"',
  })
  -- Only sudo's own options are read: they end at `--` or at the command,
  -- whose `-S` (`pacman -S`) is not sudo's. The options taking a value skip
  -- it, so `-u -S` would not read as `-S` either.
  write_script(vim.fs.joinpath(dir, 'sudo'), {
    'value=',
    'for arg in "$@"; do',
    '  if [ -n "$value" ]; then value=; continue; fi',
    '  case "$arg" in',
    ('    -S | --stdin | -[AbEeHiKklnPsVv]*S*) exec %s "$@" ;;'):format(
      q(opts.sudo)
    ),
    '    -[CDghpRrTtUu] | --chdir | --chroot | --close-from | --group | \\',
    '      --host | --prompt | --role | --type | --command-timeout | \\',
    '      --other-user | --user) value=1 ;;',
    '    --) break ;;',
    '    -*) ;;',
    '    *) break ;;',
    '  esac',
    'done',
    ('exec %s -A "$@"'):format(q(opts.sudo)),
  })
  return askpass
end

---@param source RegistryPackageSource
---@param purl Purl
function M.parse(source, purl)
  local Result = require('mason-core.result')
  if purl.namespace then
    return Result.failure(
      ('dytoy names a tool without a namespace, got %q.'):format(
        purl.namespace .. '/' .. purl.name
      )
    )
  end
  ---@class ParsedDytoySource : ParsedPackageSource
  local parsed = { tool = purl.name }
  return Result.success(parsed)
end

--- Where every command of the package runs from outside mason
---
--- A command nothing runs is mapped to `false`, so the caller can tell which
--- are still missing.
---@param ctx InstallContext
---@param skip string[]
---@return table<string, string|false>
local function locate(ctx, skip)
  local found = {}
  for command in pairs(ctx.package.spec.bin or {}) do
    found[command] = M.resolve(command, { skip = skip }) or false
  end
  return found
end

--- Run `dytoy --tool`, with a `sudo` that asks through this Neovim
---@async
---@param ctx InstallContext
---@param tool string
local function run_dytoy(ctx, tool)
  local Result = require('mason-core.result')
  local a = require('mason-core.async')

  a.scheduler()
  if vim.fn.executable('dytoy') == 0 then
    return Result.failure(
      ('dytoy is not installed, and %s is missing.'):format(tool)
    )
  end
  local helpers = vim.fn.tempname()
  vim.fn.mkdir(helpers, 'p', tonumber('700', 8))
  local token = (
    vim.uv
      .random(16)
      :gsub('.', function(c) return ('%02x'):format(c:byte()) end)
  )
  local server = vim.v.servername ~= '' and vim.v.servername
    or vim.fn.serverstart()
  local sudo = vim.fn.exepath('sudo')

  local env = { NO_COLOR = '1' }
  local with_paths = {}
  if sudo ~= '' then
    env.SUDO_ASKPASS = M.write_helpers(helpers, {
      sudo = sudo,
      nvim = vim.v.progpath,
      server = server,
      token = token,
    })
    with_paths = { helpers }
  end

  M.pending[token] = tool
  ctx.stdio_sink:stdout(('Installing %s with dytoy…\n'):format(tool))
  local result = ctx.spawn.dytoy({
    '--no-tui',
    '--tool',
    tool,
    env = env,
    with_paths = with_paths,
  })

  a.scheduler()
  M.pending[token] = nil
  vim.fn.delete(helpers, 'rf')
  return result
end

--- Link every `bin` entry of the package to where its command runs from
---
--- A link rather than a wrapper script: a formatter run through
--- `mason/bin` would otherwise start a shell first on every call. Following
--- the link keeps the name it was called by, which is all a mise shim reads
--- to know which tool it stands for.
---@param ctx InstallContext
---@param found table<string, string>
local function link(ctx, found)
  local Result = require('mason-core.result')
  return Result.try(function(try)
    for command, target in pairs(ctx.package.spec.bin or {}) do
      local real = found[command]
      local path = vim.fs.joinpath(ctx.cwd:get(), target)
      ctx.stdio_sink:stdout(('Linking %s -> %s\n'):format(command, real))
      vim.fn.mkdir(vim.fs.dirname(path), 'p')
      local ok, err = vim.uv.fs_symlink(real, path)
      if not ok then try(Result.failure(err)) end
    end
  end)
end

--- Install the tool with dytoy, unless every command it gives is already
--- there, and link its commands into the package
---
--- dytoy would skip an installed tool by itself, but going without it lets a
--- machine that has the commands -- a container, a fresh clone -- use the
--- package before dytoy is set up.
---@async
---@param ctx InstallContext
---@param source ParsedDytoySource
function M.install(ctx, source)
  local Result = require('mason-core.result')
  local a = require('mason-core.async')
  local skip =
    { require('mason-core.installer.InstallLocation').global():bin() }

  return Result.try(function(try)
    a.scheduler()
    local found = locate(ctx, skip)
    if vim.tbl_contains(vim.tbl_values(found), false) then
      try(run_dytoy(ctx, source.tool))
      a.scheduler()
      found = locate(ctx, skip)
    else
      ctx.stdio_sink:stdout(
        ('%s is already installed, linking it.\n'):format(source.tool)
      )
    end
    for command, real in pairs(found) do
      if not real then
        try(
          Result.failure(
            ('dytoy installed nothing that runs %q.'):format(command)
          )
        )
      end
    end
    try(link(ctx, found))
  end)
end

---@async
function M.get_versions()
  return require('mason-core.result').failure(
    'dytoy installs the version its own definition names.'
  )
end

--- Teach mason the `pkg:dytoy/...` type
---
--- mason keeps its package types in a table it fills on load, with no setting
--- for more; registering before the first install is all it takes.
function M.register()
  require('mason-core.installer.compiler').register_compiler('dytoy', M)
end

return M
