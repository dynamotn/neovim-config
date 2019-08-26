" vim:foldmethod=marker:foldmarker={,}
" Define key binding and add to guide {
function! dynamo#mapping#Define(type, main_key, follow_key, command, description) abort
  let feedkeys_mode = 'm'
  let map = split(a:type)[0]
  if map =~# 'nore'
    let feedkeys_mode = 'n'
  endif
  let gexe = substitute(a:command, '|', '\\|', 'g')
  exec a:type . ' ' . a:main_key . a:follow_key . ' ' . gexe

  let list_map = g:guide_map[dynamo#string#GetKeyStroke(a:main_key)]
  let follow_keys = dynamo#string#GetKeyStroke(a:follow_key)
  for i in range(1, len(follow_keys))
    let last_follow_key = follow_keys[i-1:i-1]
    if i !=? len(follow_keys)
      if !has_key(list_map, last_follow_key)
        let list_map[last_follow_key] = { 'name' : 'new group' }
      endif
      let list_map = get(list_map, last_follow_key, {})
    endif
  endfor
  let gexe = substitute(gexe, '<\([a-zA-Z-]\+\)>', '\\<\1>', 'g')
  call extend(list_map, { last_follow_key :
        \ ['call feedkeys("' . gexe . '", "' . feedkeys_mode . '")'
        \ , a:description]
        \ })
endfunction " }

" Add a group key to guide {
function! dynamo#mapping#Group(main_key, follow_key, description) abort
  let g:guide_map[dynamo#string#GetKeyStroke(a:main_key)][dynamo#string#GetKeyStroke(a:follow_key)] = { 'name' : a:description }
endfunction " }
