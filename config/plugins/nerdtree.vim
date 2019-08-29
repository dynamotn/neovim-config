" Show bookmarks
let g:NERDTreeShowBookmarks=1

" Open automatically when starts up with no files
augroup NERDTreeStartup
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if !argc() && !exists("s:std_in") | NERDTree | endif
augroup END

" Close vim if is the only window open
augroup NERDTreeAutoQuit
  autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END

" Position
let g:NERDTreeWinPos='right'
