-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--    General Neovim key mappings    --
---------------------------------------
local g = vim.g -- Global variables

local function cabbrev(input, replace)
  vim.cmd({ cmd = 'cnoreabbrev', args = { input, replace } })
end

local function map(mode, input, replace, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', opts, options)
  end
  vim.api.nvim_set_keymap(mode, input, replace, options)
end

----------- Base ------------ {
-- Change leader to \
g.leader = '\\'

-- Need help, but I can type on my own
map('', '<F1>', '<Esc>')

-- Clear search
map('n', '<Esc>', ':noh<CR><Esc>')
----------------------------- }

------ Save and Exit -------- {
-- Save with root permission
map('c', 'ww', 'w ! sudo tee % > /dev/null', { desc = 'Save with root permission' })

-- No one is really happy until you have this shortcuts
cabbrev('W!', 'w!')
cabbrev('Q!', 'q!')
cabbrev('Qa!', 'qa!')
cabbrev('Wq', 'wq')
cabbrev('Wa', 'wa')
cabbrev('wQ', 'wq')
cabbrev('WQ', 'wq')
cabbrev('W', 'w')
cabbrev('Q', 'q')
cabbrev('Qa', 'qa')
----------------------------- }

---------- Window ----------- {
-- Resize window
map('n', '<C-j>', ':resize +5<CR>')
map('n', '<C-k>', ':resize -5<CR>')
map('n', '<C-h>', ':vert resize +5<CR>')
map('n', '<C-l>', ':vert resize -5<CR>')
----------------------------- }

---------- Editing ---------- {
-- Change indentation with multiple level
map('v', '<', '<gv')
map('v', '>', '>gv')
map('n', '<', '<<_')
map('n', '>', '>>_')

-- Copy to system clipboard
map('v', '<C-c>', '"+y')
map('n', '<C-c>', '"+yy')

-- Replace selected text without copying it
map('v', 'p', '"_dP')

-- Move line to after next line or before previous line
map('i', '<A-j>', '<Esc>:m .+1<CR>==gi')
map('i', '<A-k>', '<Esc>:m .-2<CR>==gi')
map('n', '<A-j>', ':m .+1<CR>==')
map('n', '<A-k>', ':m .-2<CR>==')

-- Insert empty lines
map('n', '[<Space>', ':<C-u>put! =repeat(nr2char(10), v:count1)<CR>')
map('n', ']<Space>', ':<C-u>put =repeat(nr2char(10), v:count1)<CR>')
--------------------------- }

-------- Completion ------- {
map('i', '<Esc>', [[pumvisible() ? "<C-e><Esc>" : "<Esc>"]], { expr = true })
map('i', '<C-c>', [[pumvisible() ? "<C-e><C-c>" : "<C-c>"]], { expr = true })
map('i', '<Tab>', [[pumvisible() ? "<C-n>" : "<Tab>"]], { expr = true })
map('i', '<S-Tab>', [[pumvisible() ? "<C-p>" : "<BS>"]], { expr = true })
--------------------------- }
