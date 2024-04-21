local null_ls = require('null-ls')
local languages = require('languages')

local augroup = require('core.augroup')
local configs = languages.setup_null_ls()
local sources = {}
for _, tool in pairs(configs) do
  table.insert(sources, tool)
end

table.insert(sources, null_ls.builtins.diagnostics.trail_space)
if vim.fn.executable('git') == 1 then
  table.insert(sources, null_ls.builtins.code_actions.gitrebase)
end
if vim.fn.executable('ec') == 1 then
  table.insert(
    sources,
    null_ls.builtins.diagnostics.editorconfig_checker.with({
      command = 'ec',
    })
  )
end
if vim.fn.executable('vale') == 1 then
  table.insert(sources, null_ls.builtins.diagnostics.vale)
end

null_ls.setup({
  sources = sources,
})
