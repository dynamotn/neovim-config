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

" ------------ UI ------------ {
" Status line looks nicer
set laststatus=2

" More natural split opening
set splitbelow
set splitright

" Abbrev. of messages
set shortmess+=filmnrxoOtT

" View specific settings to save and restore view of a file
" Better Unix / Windows compatibility
set viewoptions=folds,options,cursor,unix,slash

" Enable syntax of file
syntax on

" Highlight unwanted space
set list
set listchars=tab:→\ ,eol:↵,trail:·,extends:↷,precedes:↶

" -- Current position -- {
" Show number of line
set number
set relativenumber
" Highlight current line
set cursorline
" Line number of current row will have same background color in relative mode
highlight clear LineNr
" ---------------------- }

" Elegant view
set background=dark
colorscheme hybrid " Set to end of UI section to correct color
" ---------------------------- }
