-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--    General Neovim key mappings    --
---------------------------------------
local opt = vim.opt -- Set options (global/buffer/windows-scoped)
local g = vim.g -- Global variables

local function cabbrev(input, replace)
    cmd = 'cnoreabbrev %s %s'
    vim.cmd(cmd:format(input, replace))
end

local function map(mode, input, replace, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_set_keymap(mode, input, replace, options)
end

----------- Base ------------ {
-- Change leader to \
g.leader = '\\'

-- Need help, but I can type on my own
map('', '<F1>', '<Esc>')

-- Copy paste, stackoverflow =]]
opt.pastetoggle = '<F3>'
----------------------------- }

------ Save and Exit -------- {
-- Save with root permission
map('c', 'w!!', 'w ! sudo tee % > /dev/null')

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
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-l>', '<C-w>l')
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
--------------------------- }
