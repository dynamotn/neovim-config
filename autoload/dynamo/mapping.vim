" vim:foldmethod=marker:foldmarker={,}
scriptencoding utf-8
" Define key binding and add to guide {
function! dynamo#mapping#Define(map_cmds, main_key, follow_key, command, description, ...) abort
  " Create escape char for pipe of command
  let gexe=substitute(a:command, '|', '\\|', 'g')

  " Map key binding
  let map_attr=get(a:, 1, 'silent')
  let map_cmds=a:map_cmds
  if type(a:map_cmds) == 1
    let map_cmds=[a:map_cmds]
  endif
  for map_cmd in map_cmds
    exec map_cmd . ' <' . map_attr . '> ' . a:main_key . a:follow_key . ' ' . gexe
  endfor

  " Get mapping key of guide
  let list_map=g:guide_map[a:main_key] " Only get first key of main_key

  " Iterate over keystrokes of follow_keys except last keystroke
  let follow_keystrokes=dynamo#string#GetKeyStroke(a:follow_key)
  let last_follow_keystroke=''
  let i=0
  for follow_keystroke in follow_keystrokes
    if i ==? len(follow_keystrokes) - 1
      let last_follow_keystroke=follow_keystroke
      break
    endif
    " Create group name description when don't have group of key
    if !has_key(list_map, follow_keystroke)
      let list_map[follow_keystroke]={ 'name' : '⍟ new group' }
    endif
    " Get children mapping key of group
    let list_map=get(list_map, follow_keystroke, {})
    let i+=1
  endfor

  " Update to mapping key of guide
  let list_map[last_follow_keystroke]=a:description
endfunction
" }

" Add a group key to guide {
function! dynamo#mapping#Group(main_key, follow_key, description) abort
  let list_follow_keystrokes=dynamo#string#GetKeyStroke(a:follow_key)
  let i=0
  let list_map=g:guide_map[a:main_key]
  for keystroke in list_follow_keystrokes
    let i+=1
    if i != len(list_follow_keystrokes)
      if !has_key(list_map, keystroke)
        return
      endif
      let list_map=list_map[keystroke]
    endif
  endfor
  let list_map[keystroke]={ 'name' : '⍟ ' . a:description }
endfunction
" }

" Smart key bindings for Tab in edit mode {
function! dynamo#mapping#Tab() abort
  if getline('.')[col('.')-2] ==# '{'&& pumvisible() " }
    return "\<C-n>"
  endif
  if neosnippet#expandable() && getline('.')[col('.')-2] ==# '(' && !pumvisible()
    return "\<Plug>(neosnippet_expand)"
  elseif neosnippet#jumpable()
        \ && getline('.')[col('.')-2] ==# '(' && !pumvisible()
        \ && !neosnippet#expandable()
    return "\<Plug>(neosnippet_jump)"
  elseif neosnippet#expandable_or_jumpable() && getline('.')[col('.')-2] !=#'('
    return "\<Plug>(neosnippet_expand_or_jump)"
  elseif pumvisible()
    return "\<C-n>"
  else
    return "\<Tab>"
  endif
endfunction
" }

" Smart key bindings for Enter in edit mode {
function! dynamo#mapping#Enter() abort
  if pumvisible()
    if neosnippet#expandable()
      return "\<Plug>(neosnippet_expand)"
    else
      return "\<C-y>"
    endif
  elseif getline('.')[col('.') - 2] ==# '{'&&getline('.')[col('.')-1] ==# '}'
    return "\<CR>\<Esc>ko"
  elseif getline('.')[col('.') - 2] ==# '('&&getline('.')[col('.')-1] ==# ')'
    return "\<CR>\<Esc>ko"
  else
    return "\<CR>"
  endif
endfunction
" }
