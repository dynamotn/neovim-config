" vim:foldmethod=marker:foldmarker={,}
scriptencoding utf-8
" Custom fold text function (cleaner than default) {
function! dynamo#ui#FoldText() abort
  let fs=v:foldstart
  while getline(fs) =~# '^\s*$' | let fs=nextnonblank(fs + 1)
  endwhile
  if fs > v:foldend
    let line=getline(v:foldstart)
  else
    let line=substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
    if &filetype ==# 'conf'
      if v:foldlevel == 1
        let line=getline(v:foldstart+1)[2:-2]
      else
        let line=getline(v:foldstart)[(v:foldlevel + 1):]
      endif
    endif
  endif

  let repeat_symbol='·'
  let fold_size=1 + v:foldend - v:foldstart
  let fold_size_str=' ' . fold_size . ' lines '
  let fold_level_str=repeat('|', v:foldlevel)
  let w=winwidth(0) - &foldcolumn - (&number ? 8 : 0) "8: max character for number line
  let expansion_string=repeat(repeat_symbol, w - strwidth(fold_size_str . line . fold_level_str))
  return line . expansion_string . fold_size_str . fold_level_str
endfunction
" }
