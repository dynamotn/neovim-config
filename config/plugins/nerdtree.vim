" Show bookmarks
let g:NERDTreeShowBookmarks=1

" Open automatically when starts up with no files or a folder
augroup NERDTreeStartup
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if !argc() && !exists("s:std_in") | NERDTree | endif
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exec 'NERDTree' argv()[0] | wincmd p | enew | exec 'cd '.argv()[0] | endif
augroup END

" Close vim if is the only window open
augroup NERDTreeAutoQuit
  autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END

" Position
let g:NERDTreeWinPos='right'
