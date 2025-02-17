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
