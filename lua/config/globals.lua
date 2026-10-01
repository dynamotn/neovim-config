--- Globals shared across the whole configuration
---
--- Plugin specs keep reading these off `_G`, so nothing about the access path
--- changes. What changes is that the declarations, their defaults and their
--- types sit together in one file, instead of being spread over the top of
--- `init.lua` with nothing to say what any of them holds. `per_machine` is
--- loaded afterwards and is free to override every one of them.

---@type boolean Flag to set background. Read as the manual choice whenever
--- `_G.day_night.enabled` is off, and overwritten by the clock when it is on.
_G.dark_mode = true

---@class DyDayNight
---@field enabled boolean Let the clock decide `_G.dark_mode`
---@field day_start integer Hour the light half begins, 0-23
---@field night_start integer Hour the dark half begins, 0-23

---@type DyDayNight When to be light and when to be dark. Turn `enabled` off
--- on a machine that should stay on whatever `_G.dark_mode` says.
_G.day_night = {
  enabled = false,
  day_start = 6,
  night_start = 18,
}

---@type boolean Flag to install Gentoo syntax
_G.is_gentoo = false

---@type boolean Flag to install all plugins, useful for update `lazy-lock.json`
_G.used_full_plugins = false

---@alias DyPluginChannel
---| 'latest' # LazyVim `main` and every plugin at its newest commit; needs a Neovim nightly
---| 'stable' # LazyVim and every plugin that tags releases on its newest release

---@type DyPluginChannel What `:Lazy update` moves plugins to. `latest` gets
--- fixes the day they land and breakage with them; `stable` trades that for
--- releases the plugin authors vouched for, and a released Neovim. Each keeps
--- its own lockfile, so machines on different channels never rewrite each
--- other's pins.
_G.plugin_channel = 'latest'

---@class DyEnabledPlugins
---@field obsidian boolean
---@field leetcode boolean
---@field otter boolean
---@field firenvim boolean
---@field chezmoi boolean

---@type DyEnabledPlugins List of flag to enable each misc plugin
_G.enabled_plugins = {
  obsidian = false,
  leetcode = false,
  otter = false,
  firenvim = false,
  chezmoi = false,
}

---@type string[] List enable each language, useful for install only plugins
--- for needed language. Default is all supported languages.
_G.enabled_languages = vim.tbl_keys(require('config.languages'))

---@type string[] List bundle language, include TS parsers, LSP servers, DAP
--- adapters, Linters and Formatters. Useful for containerize
_G.bundle_languages = {}

---@type string[] Name of completion sources, display when show completion menu
_G.completion_sources = {}

---@type string[] Directories of JSON and YAML schemas on this machine, offered
--- by the YAML schema picker next to those it finds in the project
_G.yaml_schema_dirs = {}

---@type string Test strategy for vim-test
_G.test_strategy = 'toggleterm'
if vim.env.ZELLIJ ~= nil then _G.test_strategy = 'zellij' end

---@type fun(...): ... Custom code for better inspection
_G.dd = function(...) require('snacks.debug').inspect(...) end

-- `:lua =expr` and a fair number of plugins go through `vim.print`, and they
-- expect their arguments handed straight back. Snacks' notifier also wants a
-- UI to draw on, so the built-in keeps the job wherever there is none, such as
-- `--headless` and `nvim -l`.
--
-- Whether a UI is attached is remembered rather than asked on every call:
-- `nvim_list_uis` throws in a fast event context, and `print` reaches here
-- from libuv callbacks -- a Mason install is one of them. The built-in copes
-- with a fast event, the notifier does not, so that case goes to it as well.
local builtin_print = vim.print
local has_ui = #vim.api.nvim_list_uis() > 0
vim.api.nvim_create_autocmd({ 'UIEnter', 'UILeave' }, {
  group = vim.api.nvim_create_augroup('dy_print_ui', { clear = true }),
  -- Counted once the event is over: a UI on its way out is still listed while
  -- `UILeave` runs.
  callback = function()
    vim.schedule(function() has_ui = #vim.api.nvim_list_uis() > 0 end)
  end,
})
vim.print = function(...)
  if not has_ui or vim.in_fast_event() then return builtin_print(...) end
  _G.dd(...)
  return ...
end

---@class DyObsidian
---@field paths table<string, string> Vault name to its folder
---@field vaults fun(): { name: string, path: string }[]
---@field todo_path fun(): string

-- Built in one piece: the fields are read back through `_G.obsidian`, so
-- `per_machine` can still swap any of them out afterwards.
---@type DyObsidian Obsidian vaults
_G.obsidian = {
  paths = {
    personal = vim.fn.expand('$HOME/Documents/Notes'),
  },
  vaults = function()
    local result = {}
    for name, path in pairs(_G.obsidian.paths) do
      table.insert(result, {
        name = name,
        path = path,
      })
    end
    return result
  end,
  todo_path = function()
    return _G.obsidian.paths.personal .. '/01_Fleeting/TODO.md'
  end,
}

---@type table<string, { priority: integer, takeover: string }> Firenvim setting
_G.firenvim_site_settings = {}

---@type string Folder of word lists (`*.txt`), fed to the dictionary
--- completion source and to `:DySpell`. Nothing breaks when it is missing:
--- completion just has no dictionary words.
_G.dictionaries_path = vim.fs.joinpath(
  vim.env.XDG_CONFIG_HOME or vim.fn.expand('~/.config'),
  'dictionaries'
)

---@type string Where locally developed plugins are checked out, for `dev` specs.
--- `NVIM_DEV_PLUGINS` points it elsewhere without editing any file, and
--- `per_machine` may still override it. The folder need not exist: lazy.nvim
--- falls back to the git remote for any plugin missing from it.
_G.dev_plugins_path = vim.env.NVIM_DEV_PLUGINS or '~/Working/community/nvim'
