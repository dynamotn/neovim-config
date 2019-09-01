" vim:foldmethod=marker:foldmarker={,}
" Get Python version {
function! dynamo#misc#InitPythonVersion() abort
  let g:dynamo_python_version = 0
  let g:dynamo_python3_version = 0
  for feature in ['python', 'python3']
    if has(feature)
      exec feature . " import vim; from sys import version_info as v; vim.command('let g:dynamo_" . feature . "_version=%s' % (v[0] * 100 + v[1] +  v[2] / 100.0))"
    endif
  endfor
endfunction " }
