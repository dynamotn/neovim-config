" vim:foldmethod=marker:foldmarker={,}
" --------- General ---------- {
if &compatible
  set nocompatible
endif
" ---------------------------- }

" ------ Plugin Manager ------ {
" Automatically install vim-plug
call dynamo#file#DownloadPluginManager()

" Load plugin
call plug#begin($VIMHOME . '/bundles')
call dynamo#file#LoadConfig('plugin')
call plug#end()
call dynamo#file#LoadConfig('key_binding')
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
if has("termguicolors")
  set termguicolors
  call dynamo#time#AutoDayNight('colorscheme PaperColor', 'colorscheme one')
else
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
  autocmd BufReadPost * silent! normal! g`"zv
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
set completeopt=menu,menuone,longest
" Limit completion menu height
set pumheight=15
" --------------- }
" ---------------------------- }
