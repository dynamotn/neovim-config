" vim:foldmethod=marker:foldmarker={,}
scriptencoding utf-8
" --------- General ---------- {
if &compatible
  set nocompatible
endif
let g:dynamo_plugins_folder='bundles'
let g:dynamo_list_plugins_file='list_plugins'
let g:dynamo_plugin_configs_folder='plugins/options'
let g:dynamo_list_key_bindings_folder='plugins/key_bindings'
let g:dynamo_common_key_bindings_file='key_bindings'
let g:dynamo_language_plugins_folder='plugins/languages'
let g:dynamo_lsp_server_install_cmd=[]
call dynamo#misc#InitPythonVersion()
" ---------------------------- }

" ------ Plugin Manager ------ {
" Automatically install vim-plug
call dynamo#file#DownloadPluginManager()

" Load plugin
call dynamo#file#InitPluginOption()
call dynamo#file#InitPluginKeyBinding()
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

" Not show redundant mode line with airline
set noshowmode

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
" Set to end of UI section to correct color
if has('termguicolors')
  if !has('nvim')
    let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
  endif
  set termguicolors
  call dynamo#time#AutoDayNight('colorscheme PaperColor', 'colorscheme one')
else
  set t_Co=256
  let &t_AB="\<Esc>[48;5;%dm"
  let &t_AF="\<Esc>[38;5;%dm"
  set background=dark
  colorscheme hybrid
endif
" ---------------------------- }

" ---- File manipulation ----- {
" End of line setting
set fileformat=unix

" Accept modeline of each file
set modeline
set modelines=1

" Return to last edit position when opening files
augroup LastPosition
  autocmd!
  autocmd BufWinEnter * call dynamo#misc#LastPosition()
augroup END

" Not backup
set nobackup
set nowritebackup
set noswapfile

call dynamo#file#LoadConfig('file_specific')
" ---------------------------- }

" ---------- Tweaks ---------- {
" Don't redraw when using macro
set lazyredraw

" Wrap
set textwidth=0
set wrapmargin=0
set wrap
set linebreak

" Flexible backspace
set backspace=indent,eol,start

" Not use mouse
set mouse-=a

" Allow to change terminal's title
set title

" Automatically read a file changed outside of vim
set autoread

" End of word designator
set iskeyword-=.#-

" Allow the cursor to move just past the end of the line
set virtualedit=onemore

" Set viminfo location
if has('nvim')
  set viminfo+=n$VIMHOME/nviminfo
else
  set viminfo+=n$VIMHOME/viminfo
end

" Timeout of key sequence
set timeoutlen=500

" -- Search -- {
" Find as you type search
set incsearch
" Highlight search terms
set hlsearch
" Smart search
set smartcase
" ------------ }

" -- Indent -- {
" Tab tweak
set expandtab
set smarttab
set shiftwidth=2
set softtabstop=2
" Automatically indent
set autoindent
filetype plugin indent on
" ------------ }

" -- Size -- {
" Command and search max history
set history=50
" Undo history
set undolevels=50
" ---------- }

" -- Folding -- {
" Set marker
set foldenable
set foldmethod=marker
set foldmarker={,}
" What movements open folds
set foldopen=block,hor,mark,percent,quickfix,tag,jump,search,undo
set foldtext=dynamo#ui#FoldText()
" ------------- }
" ---------------------------- }

" ------- Autocomplete-------- {
" -- Command mode -- {
set wildmenu
set wildmode=list:longest,list:full
set wildignorecase
" ------------------ }

" -- Edit mode -- {
set completeopt=menu,menuone,preview
" Limit completion menu height
set pumheight=15
" --------------- }
" ---------------------------- }
