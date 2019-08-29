" Guide for Space key
nnoremap <silent> <Space> :<C-u>WhichKey '<Space>'<CR>
vnoremap <silent> <Space> :<C-u>WhichKeyVisual '<Space>'<CR>
" Guide for leader key
nnoremap <silent> <leader> :<C-u>WhichKey get(g:, 'mapleader', '\')<CR>
vnoremap <silent> <leader> :<C-u>WhichKeyVisual get(g:, 'mapleader', '\')<CR>
