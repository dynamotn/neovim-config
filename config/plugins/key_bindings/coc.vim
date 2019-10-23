" LSP completion
inoremap <silent><expr> <C-Space> coc#refresh()

" Goto ... of LSP
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Refactor
nmap <silent> <F2> <Plug>(coc-rename)
