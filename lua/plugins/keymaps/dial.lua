local present, dial = pcall(require, 'dial.config')

if not present then
  return
end

vim.api.nvim_set_keymap('n', '<C-a>', require('dial.map').inc_normal(), { noremap = true })
vim.api.nvim_set_keymap('n', '<C-x>', require('dial.map').dec_normal(), { noremap = true })
vim.api.nvim_set_keymap('v', '<C-a>', require('dial.map').inc_visual(), { noremap = true })
vim.api.nvim_set_keymap('v', '<C-x>', require('dial.map').dec_visual(), { noremap = true })
vim.api.nvim_set_keymap('v', 'g<C-a>', require('dial.map').inc_gvisual(), { noremap = true })
vim.api.nvim_set_keymap('v', 'g<C-x>', require('dial.map').dec_gvisual(), { noremap = true })
