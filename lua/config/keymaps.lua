--- Create command abbreviation
---@param input string key sequence
---@param replace string key sequence
local function cabbrev(input, replace)
  vim.cmd({ cmd = 'cnoreabbrev', args = { input, replace } })
end

-- Save with root permission
vim.keymap.set(
  'c',
  'ww',
  'w ! sudo tee % > /dev/null',
  { desc = 'Save with root permission' }
)

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

-- Smart delete
local smart_delete = function(key)
  local l = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, l - 1, l, true)[1]
  return (line:match('^%s*$') and '"_' or '') .. key
end

local keys = { 'd', 'dd', 'x', 'c', 's', 'C', 'S', 'X' }
for _, key in pairs(keys) do
  vim.keymap.set(
    { 'n', 'v' },
    key,
    function() return smart_delete(key) end,
    { noremap = true, expr = true, desc = 'Smart delete' }
  )
end

-- Replace selected text without copying it
vim.keymap.set('v', 'p', '"_dP', { desc = 'Paste' })

-- Fast tab
for number = 1, 9 do
  vim.keymap.set(
    'n',
    '<leader><tab>' .. number,
    '<cmd>tabn' .. number .. '<cr>',
    { desc = 'Go to Tab ' .. number }
  )
end
