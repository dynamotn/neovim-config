" Better name
let g:which_key_default_group_name='No name'
let g:which_key_use_floating_win=0
" Base SPACE menu
let g:guide_space_map={}

" Base leader menu
let g:guide_leader_map={}

" All menus
let g:guide_map={}
let g:guide_map['<Space>']=g:guide_space_map
let g:guide_map['<leader>']=g:guide_leader_map
call which_key#register('<Space>', 'g:guide_space_map')
call which_key#register(get(g:, 'mapleader', '\'), 'g:guide_leader_map')
