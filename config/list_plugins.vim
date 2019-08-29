" vim:foldmethod=marker:foldmarker={,}
" ------- Color scheme ------- {
" For 256 color
Plug 'w0ng/vim-hybrid'
" For day time
Plug 'NLKNguyen/papercolor-theme'
" For night time
Plug 'rakr/vim-one'
call dynamo#file#RegisterPlugin('colorscheme')
" ---------------------------- }

" -------- Eyecandy ---------- {
" -- General GUI -- {
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
call dynamo#file#RegisterPlugin('airline')
" ----------------- }

" -- Text -- {
if v:version >= 800
  Plug 'chrisbra/Colorizer'
  call dynamo#file#RegisterPlugin('colorizer')
else
  Plug 'lilydjwg/colorizer'
endif
" ---------- }

" -- Icon -- {
Plug 'ryanoasis/vim-devicons'
" ---------- }

" -- Indent -- {
if v:version >= 702
  Plug 'nathanaelkane/vim-indent-guides'
  call dynamo#file#RegisterPlugin('indent_guide')
end
" ------------ }

" -- Parentheses -- {
Plug 'luochen1990/rainbow'
call dynamo#file#RegisterPlugin('rainbow')
" ----------------- }
" ---------------------------- }

" --------- Terminal --------- {
if v:version >= 800
  Plug 'Shougo/deol.nvim', { 'on': 'Deol' }
  call dynamo#file#RegisterPlugin('deol')
else
  Plug 'Shougo/vimshell.vim', { 'on': 'VimShell' } | Plug 'Shougo/vimproc.vim', { 'do' : 'make', 'on': 'VimShell' }
  call dynamo#file#RegisterPlugin('vimshell')
endif
" ---------------------------- }

" ---------- Guide ----------- {
Plug 'liuchengxu/vim-which-key'
call dynamo#file#RegisterPlugin('which_key')
" ---------------------------- }

" -------- Navigation -------- {
" -- Window -- {
" Interactive choose window
Plug 't9md/vim-choosewin', { 'on': '<Plug>(choosewin)' }
call dynamo#file#RegisterPlugin('choosewin')
" ------------ }

" -- File explorer -- {
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' } | Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
call dynamo#file#RegisterPlugin('nerdtree')
" ------------------- }
" ---------------------------- }

" ----------- Git ------------ {
" Show git hunks at ruler
if has('signs')
  Plug 'airblade/vim-gitgutter'
  call dynamo#file#RegisterPlugin('gitgutter')
endif

" Wrapper
Plug 'tpope/vim-fugitive'
" ---------------------------- }

" -------- Completion -------- {
" -- Code -- {
if v:version >= 800 && has('python3') && has('timers')
  if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  else
    Plug 'Shougo/deoplete.nvim' | Plug 'roxma/nvim-yarp' |  Plug 'roxma/vim-hug-neovim-rpc'
  endif
  call dynamo#file#RegisterPlugin('deoplete')
elseif v:version >= 703 && has('lua')
  Plug 'Shougo/neocomplete.vim'
  call dynamo#file#RegisterPlugin('neocomplete')
endif
" ---------- }

" -- Typing -- {
" Automatically insert/delete brackets, parentheses, quotes
Plug 'jiangmiao/auto-pairs'
" ----------------- }
" ---------------------------- }

" --------- Language --------- {
" -- Linter -- {
Plug 'dense-analysis/ale'
call dynamo#file#RegisterPlugin('ale')
" ------------ }

" Markdown
if has('python') || has('python3')
  if v:version >= 800
    Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': 'markdown' }
  else
    Plug 'iamcco/markdown-preview.vim', { 'for': 'markdown' }
  endif
  call dynamo#file#RegisterPlugin('markdown_preview')
endif
" ---------------------------- }
