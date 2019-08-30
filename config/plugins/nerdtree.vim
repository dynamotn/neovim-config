" Show bookmarks
let g:NERDTreeShowBookmarks=1

" Close vim if is the only window open
augroup NERDTreeAutoQuit
  autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END

" Position
let g:NERDTreeWinPos='right'
