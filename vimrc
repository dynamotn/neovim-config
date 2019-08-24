" Skip initialization for vim-tiny or vim-small.
if 1
  let $VIMHOME = fnamemodify(expand('<sfile>'), ':h') . '/.vim'
  source $VIMHOME/config/main.vim
endif
