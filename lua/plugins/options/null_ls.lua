local null_ls = require('null-ls')
local languages = require('languages')

local augroup = require('misc.augroup')
local configs = languages.setup_null_ls()
local sources = {}
for _, tool in pairs(configs) do
  table.insert(sources, tool)
end

table.insert(sources, null_ls.builtins.diagnostics.trail_space)
table.insert(sources, null_ls.builtins.formatting.trim_whitespace)
table.insert(sources, null_ls.builtins.formatting.trim_newlines)
if vim.fn.executable('git') then
  table.insert(sources, null_ls.builtins.code_actions.gitrebase)
end
if vim.fn.executable('ec') then
  table.insert(sources, null_ls.builtins.diagnostics.editorconfig_checker)
end
if vim.fn.executable('vale') then
  table.insert(sources, null_ls.builtins.diagnostics.vale)
end

null_ls.setup({
  sources = sources,
  on_attach = function(client)
    augroup.enable_formatting(client.id)
  end,
  on_exit = function(_)
    augroup.disable_formatting()
  end,
})
