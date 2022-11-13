local present, _ = pcall(require, 'luasnip')

if not present then
  return
end

require('luasnip.loaders.from_vscode').lazy_load()
require('luasnip.loaders.from_snipmate').lazy_load()
