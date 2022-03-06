-- Change the sign
vim.g.ale_sign_error = '✗✗'
vim.g.ale_sign_warning = '∆∆'
vim.g.ale_sign_info = '🛈🛈'

-- Automatically fix on save
vim.g.ale_fix_on_save = 1

-- Disable loclist and put to quickfixlist
vim.g.ale_set_loclist = 0
vim.g.ale_set_quickfix = 1

-- Show messages below status line
vim.g.ale_echo_msg_format = '[%linter%] %s [%severity%]'
