" vim:foldmethod=marker:foldmarker={,}
" Get keystroke instead <leader>, <Space>...
function! dynamo#string#GetKeyStroke(code) abort
  if a:code ==? '<leader>' || a:code ==? '<Leader>'
    return get(g:, 'mapleader', '\')
  elseif a:code ==? '<space>'|| a:code ==? '<Space>'
    return ' '
  else
    return a:code
  endif
endfunction
