" vim:foldmethod=marker:foldmarker={,}
" --------- General ---------- {
if &compatible
  set nocompatible
endif
" ---------------------------- }

" ------ Plugin Manager ------ {
" Auto install vim-plug
if empty(glob($VIMHOME . '/autoload/plug.vim'))
  silent !curl -fLo $VIMHOME/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Load plugin
call plug#begin($VIMHOME . '/bundles')
source $VIMHOME/config/plugin.vim
call plug#end()
" ---------------------------- }
