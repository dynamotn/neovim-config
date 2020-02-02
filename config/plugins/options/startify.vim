" vim:foldmethod=marker:foldmarker={,}
" Change header
let g:startify_custom_header = dynamo#misc#AsciiArt() + startify#fortune#boxed()
let g:startify_list_order = [
      \ ['   My most recently used files in the current directory:'],
      \ 'dir',
      \ ['   My most recently used files:'],
      \ 'files',
      \ ['   These are my sessions:'],
      \ 'sessions',
      \ ['   These are my bookmarks:'],
      \ 'bookmarks',
      \ ]

" Startify when startup
augroup StartifyStartup
  function! StartifyStartup() abort
    if !exists('g:dynamo_has_std_in') && argc() == 1 && isdirectory(argv()[0])
      Startify
    endif
  endfunction
  autocmd VimEnter * call StartifyStartup()
augroup END
