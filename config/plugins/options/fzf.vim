" Prefix of fzf command
let g:fzf_command_prefix='F'

" Turn off number line of fzf window
augroup FZFPlugin
  autocmd!
  autocmd FileType fzf setlocal nonumber norelativenumber
augroup END

" Add FNeoyank
command! -nargs=* FNeoyank call fzf_neoyank#show(<f-args>)
command! -nargs=* -range FNeoyank call fzf_neoyank#show_for_selection(<f-args>)
