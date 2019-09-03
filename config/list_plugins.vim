" vim:foldmethod=marker:foldmarker={,}
" ---------- General --------- {
" Vim 8 remote plugin
if !has('nvim')
  Plug 'roxma/nvim-yarp' |  Plug 'roxma/vim-hug-neovim-rpc'
endif
" ---------------------------- }

" ------- Color scheme ------- {
" For 256 color
Plug 'w0ng/vim-hybrid'
" For day time
Plug 'NLKNguyen/papercolor-theme'
" For night time
Plug 'rakr/vim-one'
call dynamo#file#RegisterPlugin('colorscheme')
" ---------------------------- }

" --------- Eyecandy --------- {
" -- Status line -- {
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
call dynamo#file#RegisterPlugin('airline')
" ----------------- }

" -- Startup screen -- {
Plug 'mhinz/vim-startify'
" -------------------- }

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

" -- Mark -- {
Plug 'kshenoy/vim-signature'
call dynamo#file#RegisterPlugin('signature')
" ---------- }
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

" --------- Framework -------- {
" Guide
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
Plug 'scrooloose/nerdtree' | Plug 'Xuyuanp/nerdtree-git-plugin'
call dynamo#file#RegisterPlugin('nerdtree')
" ------------------- }
" ---------------------------- }

" -------- Efficiency -------- {
" Show tags and LSP symbols
if executable('ctags')
  if v:version >= 800
    Plug 'liuchengxu/vista.vim'
    call dynamo#file#RegisterPlugin('vista')
  else
    Plug 'majutsushi/tagbar'
  endif
endif

" Automatically update tags
Plug 'craigemery/vim-autotag'

" Fast comment
Plug 'scrooloose/nerdcommenter'

" Show matching keyword, parentheses..., move between them
if exists('*matchaddpos')
  Plug 'andymass/vim-matchup'
endif

" Test code
Plug 'janko/vim-test' | Plug 'tpope/vim-dispatch'
call dynamo#file#RegisterPlugin('test')

" Alignment
Plug 'junegunn/vim-easy-align'
call dynamo#file#RegisterPlugin('easy_align')

" Fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } | Plug 'junegunn/fzf.vim'
" ---------------------------- }

" ----------- VCS ------------ {
" Show hunks at ruler
if has('signs')
  Plug 'mhinz/vim-signify'
endif

" Wrapper tool for Git
Plug 'tpope/vim-fugitive' | Plug 'junegunn/gv.vim'
" ---------------------------- }

" -------- Completion -------- {
" -- Code -- {
" Engine
if v:version >= 800 && has('python3') && has('timers') && g:dynamo_python3_version >= 306.01
  if has('nvim')
    let plug_param_for_deoplete = { 'do': 'UpdateRemotePlugins' }
    if !has('nvim-0.3')
      let plug_param_for_deoplete.tag = '4.1'
    endif
    Plug 'Shougo/deoplete.nvim', plug_param_for_deoplete
  else
    Plug 'Shougo/deoplete.nvim'
  endif
  call dynamo#file#RegisterPlugin('deoplete')
elseif v:version >= 703 && has('lua')
  Plug 'Shougo/neocomplete.vim'
  call dynamo#file#RegisterPlugin('neocomplete')
endif

" Display function signatures
if v:version >= 800
  Plug 'Shougo/echodoc.vim'
  call dynamo#file#RegisterPlugin('echodoc')
endif
" ---------- }

" -- Snippet -- {
" Engine
if v:version >= 704
  Plug 'Shougo/neosnippet'
  call dynamo#file#RegisterPlugin('neosnippet')
endif
Plug 'SirVer/ultisnips'

" List
Plug 'Shougo/neosnippet-snippets'
Plug 'honza/vim-snippets'
" ------------- }

" -- Typing -- {
" Automatically insert/delete brackets, parentheses, quotes
Plug 'jiangmiao/auto-pairs'
call dynamo#file#RegisterPlugin('auto_pairs')
" Automatically insert 'end' keyword
Plug 'tpope/vim-endwise'
" ----------------- }
" ---------------------------- }

" --------- Language --------- {
" -- Linter -- {
Plug 'dense-analysis/ale'
call dynamo#file#RegisterPlugin('ale')
" ------------ }

" Collection of language packs: syntax, indent ...
Plug 'sheerun/vim-polyglot'

" Load each language
call dynamo#file#LoadLanguagePlugin('markdown')
call dynamo#file#LoadLanguagePlugin('vim')
call dynamo#file#EndLoadPlugin()
" ---------------------------- }
