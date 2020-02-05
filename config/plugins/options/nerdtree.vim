" Show bookmarks
let g:NERDTreeShowBookmarks=1

" Close vim if is the only window open
augroup NERDTreeAutoQuit
  autocmd!
  autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END

" Position
let g:NERDTreeWinPos='left'

" NERDTree when startup
augroup NERDTreeStartup
  function! NERDTreeStartup() abort
    if !exists('g:dynamo_has_std_in')
      " Open automatically NERDTree when not have vim argument
      if !argc()
        NERDTree | wincmd w
      endif

      " Open automatically NERDTree when vim argument is a folder
      if argc() == 1 && isdirectory(argv()[0])
        exec 'NERDTree' argv()[0] | wincmd p
        " Change current folder to input folder
        exec 'cd '.argv()[0]
        if !dynamo#plugin#IsRegistered('startify')
          enew
        endif
      endif
    endif
  endfunction

  autocmd!
  autocmd VimEnter * call NERDTreeStartup()
augroup END
