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
local keys = { 'd', 'dd', 'x', 'c', 's', 'C', 'S', 'X' } -- Define a list of keys to apply the smart delete functionality
for _, key in pairs(keys) do
  vim.keymap.set({ 'n', 'v' }, key, function()
    local l = vim.api.nvim_win_get_cursor(0)[1] -- Get the current cursor line number
    local line = vim.api.nvim_buf_get_lines(0, l - 1, l, true)[1] -- Get the content of the current line
    return (line:match('^%s*$') and '"_' or '') .. key -- If the line is empty or contains only whitespace, use the black hole register
  end, { noremap = true, expr = true, desc = 'Smart delete' })
end

-- Replace selected text without copying it
vim.keymap.set('v', 'p', '"_dP', { desc = 'Paste' })
