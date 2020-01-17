" vim:foldmethod=marker:foldmarker={,}
" Something on startup {
augroup Startup
  autocmd StdinReadPre * let s:std_in=1
  " Open automatically NERDTree and Startify when not have vim argument
  autocmd VimEnter * if !argc() && !exists("s:std_in") | NERDTree | wincmd w | Startify | endif
  " Open automatically NERDTree and Startify when vim argument is a folder
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exec 'NERDTree' argv()[0] | wincmd p | enew | exec 'cd '.argv()[0] | Startify | endif
augroup END
" }

" Custom fold level of config file {
" ############
" # Category #
" ############
" ## Subcategory
" ### Sub-subcategory
" # Just a comment
augroup FoldConfigFile
  function! ConfigFileFolds()
    let this_line=getline(v:lnum)
    if match(this_line, '^#\{2,} ') >= 0
      return '>' . (len(this_line) - len(substitute(this_line, '^#\{2,}', '', 'g')))
    endif
    let two_following_lines=0
    if line(v:lnum) + 2 <= line('$')
      let line_1_after=getline(v:lnum+1)
      let line_2_after=getline(v:lnum+2)
      let two_following_lines=1
    endif
    if !two_following_lines
      return '='
    else
      if (match(this_line, '^#####') >= 0) &&
         \ (match(line_1_after, '^# ') >= 0) &&
         \ (match(line_2_after, '^#####') >= 0)
        return '>1'
      else
        return '='
      endif
    endif
  endfunction

  autocmd FileType conf setlocal foldmethod=expr | setlocal foldexpr=ConfigFileFolds()
augroup END
" }
