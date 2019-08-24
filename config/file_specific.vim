" vim:foldmethod=marker:foldmarker={,}
" Git commit faster, always start with first line, avoid augroup LastPosition {
function! CommitFast()
  set noreadonly
  normal! gg
endfunction
autocmd BufNewFile,BufRead COMMIT_EDITMSG,MERGE_MSG exec CommitFast()
" }
