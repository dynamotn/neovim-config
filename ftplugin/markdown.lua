-- An LSP hover is a markdown float too: not a document to spell or run
if vim.bo.buftype ~= '' then return end
vim.opt_local.wrap = true
vim.opt_local.spell = true
-- Code blocks run where they are written (`tools.runbook`)
require('tools.runbook').attach(0)
