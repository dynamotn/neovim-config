--- Create command abbreviation
---@param input string key sequence
---@param replace string key sequence
local function cabbrev(input, replace)
  vim.cmd({ cmd = 'cnoreabbrev', args = { input, replace } })
end

-- Save with root permission
vim.keymap.set('c', 'ww', 'w ! sudo tee % > /dev/null', { desc = 'Save with root permission' })

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

-- Change word faster
vim.keymap.set('n', '<C-c>', 'ciw', { desc = 'Change word' })
