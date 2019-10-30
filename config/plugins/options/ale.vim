scriptencoding utf-8
" Symbol
let g:ale_sign_error='✗✗'
let g:ale_sign_warning='∆∆'
let g:ale_sign_info='🛈🛈'

" Check and fix when save file
let g:ale_lint_on_save=1
let g:ale_fix_on_save=1

" Support virtual text for Neovim
if has('nvim-0.3.2')
  let g:ale_virtualtext_cursor = 1
endif

" Message on cmd line
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
