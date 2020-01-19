" vim:foldmethod=marker:foldmarker={,}
" Get Python version {
function! dynamo#misc#InitPythonVersion() abort
  let g:dynamo_python_version=0
  let g:dynamo_python3_version=0
  for feature in ['python', 'python3']
    if has(feature)
      exec feature . " import vim; from sys import version_info as v; vim.command('let g:dynamo_" . feature . "_version=%s' % (v[0] * 100 + v[1] +  v[2] / 100.0))"
    endif
  endfor
endfunction
" }

" Register code complete engine {
function! dynamo#misc#RegisterEngine(engine) abort
  let g:dynamo_complete_engine=a:engine
endfunction

function! dynamo#misc#HasEngine() abort
  return exists('g:dynamo_complete_engine')
endfunction
" }

" Get position of cursor of file when it is opened by vim {
function! dynamo#misc#LastPosition() abort
  " Ignore when diff
  if &diff
    return
  endif

  " Ignore of some special buffer
  if index(['quickfix', 'nofile', 'help'], &buftype) != -1
    return
  endif

  " Ignore git commit/merge, rebase file
  if index(['gitcommit','gitrebase'], &filetype) != -1
    return
  endif

  " Do nothing when file does not exist
  try
    if empty(glob(@%))
      return
    endif
  catch
    return
  endtry

  " The last edit position is set and is less than the number of lines of buffer
  if line("'\"") > 0 && line("'\"") <= line('$')
    " The last line of current buffer is also the last line visible of window
    if line('w$') == line('$')
      execute "normal! g`\""
    " At the middle or top of the file, center the cursor on the screen
    elseif line('$') - line("'\"") > ((line('w$') - line('w0')) / 2) - 1
      execute "normal! g`\"zz"
    " At the bottom of the file
    else
      execute "normal! \G'\"\<c-e>"
    endif
  endif

  " In a fold, make the current line visible and recenter screen
  if foldclosed('.') != -1
    execute 'normal! zvzz'
  endif
endfunction
" }

" Get text of visual block {
function! dynamo#misc#GetTextVisualBlock(...) abort
  let temp=@s
  normal! gv"sy
  if a:0 >= 1
    let @/=a:1(@s)
  else
    let @/=@s
  end
  let @s=temp
endfunction
" }

" My custom ASCII text {
function! dynamo#misc#AsciiArt() abort
  return [
      \ ' |$$$$$$$\',
      \ ' |$$  __$$\',
      \ ' |$$ |  $$ $$\   $$\$$$$$$$\  $$$$$$\ $$$$$$\$$$$\  $$$$$$\',
      \ ' |$$ |  $$ $$ |  $$ $$  __$$\ \____$$\$$  _$$  _$$\$$  __$$\',
      \ ' |$$ |  $$ $$ |  $$ $$ |  $$ |$$$$$$$ $$ / $$ / $$ $$ /  $$ |',
      \ ' |$$ |  $$ $$ |  $$ $$ |  $$ $$  __$$ $$ | $$ | $$ $$ |  $$ |',
      \ ' |$$$$$$$  \$$$$$$$ $$ |  $$ \$$$$$$$ $$ | $$ | $$ \$$$$$$  |',
      \ ' |________/ \____$$ \__|  \__|\_______\__| \__| \__|\______/',
      \ '          $$\   $$ |',
      \ '          \$$$$$$  |',
      \ '           \______/',
      \ ]
endfunction
" }
