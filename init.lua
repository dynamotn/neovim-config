_G.is_gentoo = false
_G.is_gui_machine = false
_G.enabled_obsidian = false
_G.enabled_leetcode = false
_G.used_full_plugins = false
_G.enabled_otter = false
_G.enabled_languages = {}
for language, _ in pairs(require('languages.list')) do
  table.insert(_G.enabled_languages, language)
end
_G.completion_sources = {
  Path = '「 PATH」',
  Snippets = '「SNIP」',
  LSP = '「LSP」',
  Buffer = '「BUF」',
}
_G.dd = function(...)
  require('snacks.debug').inspect(...)
end
vim.print = _G.dd

require('per_machine')
require('config.lazy')
