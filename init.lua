--- Flag to install Gentoo syntax
_G.is_gentoo = false
--- Flag to install all plugins, useful for update `lazy-lock.json`
_G.used_full_plugins = false
--- List of flag to enable each misc plugin
_G.enabled_plugins = {
  obsidian = false,
  leetcode = false,
  otter = false,
  firenvim = false,
  chezmoi = false,
}
--- List enable each language, useful for install only plugins for needed language. Default is all supported languages.
_G.enabled_languages = vim.tbl_keys(require('config.languages'))
--- List bundle language, include TS parsers, LSP servers, DAP adapters, Linters and Formatters. Useful for containerize
_G.bundle_languages = {}
--- Name of completion sources, display when show completion menu
_G.completion_sources = {}
--- Test strategy for vim-test
_G.test_strategy = 'toggleterm'
if vim.env.ZELLIJ ~= nil then _G.test_strategy = 'zellij' end
--- Custom code for better inspection
_G.dd = function(...) require('snacks.debug').inspect(...) end
vim.print = _G.dd
--- Obsidian vaults
_G.obsidian = {
  paths = {
    personal = '~/Documents/Notes',
  },
}
_G.obsidian.vaults = function()
  local result = {}
  for name, path in pairs(_G.obsidian.paths) do
    table.insert(result, {
      name = name,
      path = path,
    })
  end
  return result
end
_G.obsidian.todo_path = function()
  return _G.obsidian.paths.personal .. '/01_Fleeting Notes/TODO.md'
end
--- Firenvim setting
_G.firenvim_site_settings = {}
--- AI settings
_G.companion_adapter = 'ollama'

if vim.fn.has('nvim-0.10.0') == 1 then
  -- Load specific configurations per machine
  pcall(require, 'per_machine')
  pcall(require, 'per_machine_secret')
  -- Load LazyVim
  require('config.lazy')
end
