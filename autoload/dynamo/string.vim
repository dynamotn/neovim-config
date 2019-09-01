" vim:foldmethod=marker:foldmarker={,}
" Get keystroke instead <leader>, <Space>... {
function! dynamo#string#GetKeyStroke(input_keys) abort
  let keystrokes_list = []
  let i = 0
  let current_special_key = ''
  let is_special_key = 0

  while i < len(a:input_keys)
    if a:input_keys[i] ==? '<'
      let is_special_key = 1
    endif
    if is_special_key == 1
      let current_special_key .= a:input_keys[i]
    else
      let keystrokes_list = add(keystrokes_list, a:input_keys[i])
    endif
    if a:input_keys[i] ==? '>'
      let is_special_key = 0
      let keystrokes_list = add(keystrokes_list,
            \ dynamo#string#ReplaceKeyStroke(current_special_key))
      let current_special_key = ''
    endif
    let i += 1
  endwhile
  return keystrokes_list
endfunction " }

" Replace <leader>, <Space> ... to right char {
function! dynamo#string#ReplaceKeyStroke(input_key) abort
  let must_replace_keys = ['<leader>', '<space>']
  let result_keys = [get(g:, 'mapleader', '\'), ' ']

  let i = 0
  for key in must_replace_keys
    if tolower(a:input_key) == key
      return result_keys[i]
    endif
    let i += 1
  endfor
  return a:input_key
endfunction " }
