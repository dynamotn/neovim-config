" Auto run vista when startup
augroup VistaTag
  autocmd!
  autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
augroup END

" Default use universal-ctags as executive
let g:vista_default_executive='ctags'
