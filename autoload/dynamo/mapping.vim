" vim:foldmethod=marker:foldmarker={,}
scriptencoding utf-8
" Define key binding and add to guide {
function! dynamo#mapping#Define(type, main_key, follow_key, command, description) abort
  " Create escape char for pipe of command
  let gexe = substitute(a:command, '|', '\\|', 'g')

  " Map key binding
  exec a:type . ' ' . a:main_key . a:follow_key . ' ' . gexe

  " Get mapping key of guide
  let list_map = g:guide_map[dynamo#string#GetKeyStroke(a:main_key)[0]] " Only get first key of main_key

  " Iterate over keystrokes of follow_keys except last keystroke
  let follow_keystrokes = dynamo#string#GetKeyStroke(a:follow_key)
  let last_follow_keystroke = ''
  let i = 0
  for follow_keystroke in follow_keystrokes
    if i ==? len(follow_keystrokes) - 1
      let last_follow_keystroke = follow_keystroke
      break
    endif
    " Create group name description when don't have group of key
    if !has_key(list_map, follow_keystroke)
      let list_map[follow_keystroke] = { 'name' : 'new group' }
    endif
    " Get children mapping key of group
    let list_map = get(list_map, follow_keystroke, {})
    let i += 1
  endfor

  " With feedkeys function, must have backslash with special key
  let gexe = substitute(gexe, '<\([a-zA-Z-]\+\)>', '\\<\1>', 'g')
  " Create escape char for magic pattern
  let gexe = substitute(gexe, '\\\([vVmM]\)', '\\\\\1', 'g')
  let feedkeys_mode = 'm'
  let map = split(a:type)[0]
  " If type have nore keyword, then not remap key
  if map =~# 'nore'
    let feedkeys_mode = 'n'
  endif
  " Update to mapping key of guide
  call extend(list_map, { last_follow_keystroke :
        \ ['call feedkeys("' . gexe . '", "' . feedkeys_mode . '")'
        \ , a:description]
        \ })
endfunction " }

" Add a group key to guide {
function! dynamo#mapping#Group(main_key, follow_key, description) abort
  let g:guide_map[dynamo#string#GetKeyStroke(a:main_key)[0]]
        \[dynamo#string#GetKeyStroke(a:follow_key)[0]] = { 'name' : '⍟ ' . a:description }
endfunction " }
