-- Diagnostics
for name, icon in pairs(require('core.defaults').icons.diagnostics) do
  name = 'DiagnosticSign' .. name
  vim.fn.sign_define(name, { text = icon, texthl = name, numhl = '' })
end

for abbr, full_text in pairs(require('core.defaults').abbreviations) do
  vim.cmd({ cmd = 'inoreabbrev', args = {abbr, full_text} })
end
