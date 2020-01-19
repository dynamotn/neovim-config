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
