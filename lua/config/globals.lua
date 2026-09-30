--- Globals shared across the whole configuration
---
--- Plugin specs keep reading these off `_G`, so nothing about the access path
--- changes. What changes is that the declarations, their defaults and their
--- types sit together in one file, instead of being spread over the top of
--- `init.lua` with nothing to say what any of them holds. `per_machine` is
--- loaded afterwards and is free to override every one of them.

---@type boolean Flag to set background
_G.dark_mode = true

---@type boolean Flag to install Gentoo syntax
_G.is_gentoo = false

---@type boolean Flag to install all plugins, useful for update `lazy-lock.json`
_G.used_full_plugins = false

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

---@type string Test strategy for vim-test
_G.test_strategy = 'toggleterm'
if vim.env.ZELLIJ ~= nil then _G.test_strategy = 'zellij' end

---@type fun(...): ... Custom code for better inspection
_G.dd = function(...) require('snacks.debug').inspect(...) end

-- `:lua =expr` and a fair number of plugins go through `vim.print`, and they
-- expect their arguments handed straight back. Snacks' notifier also wants a
-- UI to draw on, so the built-in keeps the job wherever there is none, such as
-- `--headless` and `nvim -l`.
local builtin_print = vim.print
vim.print = function(...)
  if #vim.api.nvim_list_uis() == 0 then return builtin_print(...) end
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
