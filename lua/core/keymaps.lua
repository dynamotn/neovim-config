-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--    General Neovim key mappings    --
---------------------------------------
local opt = vim.opt -- Set options (global/buffer/windowS-scoped)
local g = vim.g -- Global variables

local function cabbrev(input, replace)
    local cmd = 'cnoreabbrev %s %s'
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
map('i', '<CR>', 'v:lua.dynamo_mapping_enter()', { expr = true })
map('i', '<BS>', 'v:lua.dynamo_mapping_backspace()', { expr = true })
--------------------------- }
