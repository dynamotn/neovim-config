" Prefix of fzf command
let g:fzf_command_prefix='FZF'

" Turn off number line of fzf window
augroup FZFPlugin
  autocmd!
  autocmd FileType fzf setlocal nonumber norelativenumber
augroup END
