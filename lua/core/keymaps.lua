-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--    General Neovim key mappings    --
---------------------------------------
local opt = vim.opt                         -- Set options (global/buffer/windows-scoped)
local g = vim.g                             -- Global variables
local map = vim.api.nvim_set_keymap         -- Map command
local default_opts = { noremap = true }

local function cabbrev(input, replace)
  cmd = 'cnoreabbrev %s %s'
  vim.cmd(cmd:format(input, replace))
end

----------- Base ------------ {
-- Change leader to \
g.leader = '\\'

-- Need help, but I can type on my own
map('', '<F1>', '<Esc>', default_opts)

-- Copy paste, stackoverflow =]]
opt.pastetoggle = '<F3>'
----------------------------- }

------ Save and Exit -------- {
-- Save with root permission
map('c', 'w!!', 'w ! sudo tee % > /dev/null', default_opts)

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
-- Navigate splited window easier
map('n', '<C-j>', '<C-w>j', default_opts)
map('n', '<C-k>', '<C-w>k', default_opts)
map('n', '<C-h>', '<C-w>h', default_opts)
map('n', '<C-l>', '<C-w>l', default_opts)
----------------------------- }

---------- Editing ---------- {
-- Change indentation with multiple level
map('v', '<', '<gv', default_opts)
map('v', '>', '>gv', default_opts)
map('n', '<', '<<_', default_opts)
map('n', '>', '>>_', default_opts)

-- Copy to system clipboard
map('v', '<C-c>', '"+y', default_opts)
map('n', '<C-c>', '"+yy', default_opts)

-- Replace selected text without copying it
map('v', 'p', '"_dP', default_opts)
----------------------------- }
