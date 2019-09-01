" vim:foldmethod=marker:foldmarker={,}
" Something on startup
augroup Startup
  autocmd StdinReadPre * let s:std_in=1
  " Open automatically NERDTree and Startify when not have vim argument
  autocmd VimEnter * if !argc() && !exists("s:std_in") | NERDTree | wincmd w | Startify | endif
  " Open automatically NERDTree and Startify when vim argument is a folder
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exec 'NERDTree' argv()[0] | wincmd p | enew | exec 'cd '.argv()[0] | Startify | endif
augroup END

" Git commit faster, always start with first line, avoid augroup LastPosition {
augroup FastCommitMessage
  autocmd BufNewFile,BufRead COMMIT_EDITMSG,MERGE_MSG set noreadonly | normal! gg
augroup END
" }
