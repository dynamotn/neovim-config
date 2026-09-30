-- Open a file of each common filetype in the configuration `check-startup.sh`
-- has just loaded, and report every error that surfaces on the way.
--
-- Starting an empty Neovim only reaches `init.lua`: the `FileType`
-- dispatcher, the language servers, linters and formatters, and every plugin
-- that loads on a buffer event are left alone. Opening real files runs them.
--
-- Two things stand in the way of seeing what goes wrong, and are dealt with
-- here:
--
-- - Headless, the notifier has no UI to draw on and drops what it is sent, so
--   an error a handler reports through `vim.notify` never reaches the output.
--   Errors are copied to stderr, where the shell script looks for them.
-- - Opening a file installs whatever its language is missing. A check must
--   not download tools behind the user's back, so installs are recorded and
--   skipped instead.

-- Files of this repository itself, one per filetype, so nothing has to be
-- written anywhere and every tool they call for is already one this
-- repository needs.
local samples = {
  'init.lua',
  'scripts/check-startup.sh',
  '.pre-commit-config.yaml',
  'README.md',
  'renovate.json',
  '.stylua.toml',
}

local errors = {} ---@type string[]
local skipped = {} ---@type string[]

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

local function skip_installs()
  local ok, mason = pcall(require, 'mason.api.command')
  if ok then
    mason.MasonInstall = function(packages) vim.list_extend(skipped, packages) end
  end
  local ok_ts, treesitter = pcall(require, 'nvim-treesitter')
  if ok_ts then
    treesitter.install = function(parsers)
      vim.list_extend(skipped, type(parsers) == 'table' and parsers or {})
      -- Callers chain `:await` onto the task `install` hands back. The
      -- callback is never run: it reloads the buffer with `:e!`, which fires
      -- `FileType` again, finds the parser still missing, and so on forever.
      return { await = function() end }
    end
  end
end

skip_installs()
local config = vim.fn.stdpath('config') --[[@as string]]
for _, sample in ipairs(samples) do
  watch_notify()
  local ok, err = pcall(vim.cmd.edit, vim.fs.joinpath(config, sample))
  if not ok then report(err) end
  -- Let scheduled work run: handlers and language servers start from
  -- callbacks, not from the `:edit` itself.
  vim.wait(200)
end

if #skipped > 0 then
  io.stdout:write(
    'check-startup: skipped installing '
      .. table.concat(LazyVim.dedup(skipped), ', ')
      .. '\n'
  )
end
for _, msg in ipairs(errors) do
  io.stderr:write('Error: ' .. msg .. '\n')
end
vim.cmd('qa!')
