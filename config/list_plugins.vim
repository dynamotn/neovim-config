" vim:foldmethod=marker:foldmarker={,}
" ---------- General --------- {
" Vim 8 remote plugin
if v:version >= 800 && !has('nvim')
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
Plug 'vim-airline/vim-airline'
call dynamo#file#RegisterPlugin('airline')
" ----------------- }

" -- Startup screen -- {
Plug 'mhinz/vim-startify'
call dynamo#file#RegisterPlugin('startify')
" -------------------- }

" -- Text -- {
if has('termguicolors') && executable('go')
  Plug 'RRethy/vim-hexokinase', { 'do': 'make hexokinase' }
  call dynamo#file#RegisterPlugin('hexokinase')
elseif v:version >= 800
  Plug 'chrisbra/Colorizer'
  call dynamo#file#RegisterPlugin('colorizer-nvim')
else
  Plug 'lilydjwg/colorizer'
  call dynamo#file#RegisterPlugin('colorizer-vim')
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
if has('signs')
  Plug 'kshenoy/vim-signature'
  call dynamo#file#RegisterPlugin('signature')
endif
" ---------- }
"
" -- Space -- {
Plug 'ntpeters/vim-better-whitespace'
call dynamo#file#RegisterPlugin('better_whitespace')
" ----------- }
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
    call dynamo#file#RegisterPlugin('tagbar')
  endif
endif

" Automatically update tags
Plug 'craigemery/vim-autotag'

" Fast comment
if v:version >= 700
  Plug 'scrooloose/nerdcommenter'
  call dynamo#file#RegisterPlugin('nerdcommenter')
endif

" Show matching keyword, parentheses..., move between them
if exists('*matchaddpos')
  Plug 'andymass/vim-matchup'
endif

" Switching between a single-line statement and a multi-line one
Plug 'AndrewRadev/splitjoin.vim'

" Test code
Plug 'janko/vim-test' | Plug 'tpope/vim-dispatch'
if has('nvim')
  Plug 'radenling/vim-dispatch-neovim'
endif
call dynamo#file#RegisterPlugin('test')

" Alignment
Plug 'junegunn/vim-easy-align'
call dynamo#file#RegisterPlugin('easy_align')

" Fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } | Plug 'junegunn/fzf.vim'
" Yank history
Plug 'Shougo/neoyank.vim' | Plug 'justinhoward/fzf-neoyank'
call dynamo#file#RegisterPlugin('fzf')

" Table mode formatter
Plug 'dhruvasagar/vim-table-mode', { 'on': ['TableModeEnable', 'TableModeToggle'] }

Plug 'tyru/open-browser-github.vim' | Plug 'tyru/open-browser.vim'
call dynamo#file#RegisterPlugin('open_browser')
" ---------------------------- }

" ----------- VCS ------------ {
" Show hunks at ruler
if has('signs')
  Plug 'mhinz/vim-signify'
endif

" Wrapper tool for Git
Plug 'tpope/vim-fugitive' | Plug 'junegunn/gv.vim'
call dynamo#file#RegisterPlugin('git')
" ---------------------------- }

" -------- Completion -------- {
" -- Code -- {
" Engine
if executable('node') && executable('yarn') && (v:version >= 800 && !has('nvim')) || has('nvim-0.3.1')
  Plug 'neoclide/coc.nvim', { 'branch': 'release' }
  call dynamo#file#RegisterPlugin('coc')
endif
if !dynamo#misc#HasEngine() && v:version >= 800 && has('python3') && has('timers') && g:dynamo_python3_version >= 306.01
  let plug_param_for_deoplete={ 'do': 'UpdateRemotePlugins' }
  if !has('nvim-0.3')
    let plug_param_for_deoplete.tag='4.1'
  endif
  Plug 'Shougo/deoplete.nvim', plug_param_for_deoplete
  call dynamo#file#RegisterPlugin('deoplete')
endif
if !dynamo#misc#HasEngine() || (v:version >= 703 && has('lua'))
  Plug 'Shougo/neocomplete.vim'
  call dynamo#file#RegisterPlugin('neocomplete')
endif
" ---------- }

" -- Snippet -- {
" Engine
if v:version >= 704
  Plug 'Shougo/neosnippet'
  call dynamo#file#RegisterPlugin('neosnippet')
endif

" List
Plug 'Shougo/neosnippet-snippets'
Plug 'honza/vim-snippets'
" ------------- }

" -- Typing -- {
" Automatically insert/delete brackets, parentheses, quotes
Plug 'jiangmiao/auto-pairs'
" Automatically insert 'end' keyword
Plug 'tpope/vim-endwise'
" ----------------- }

" -- Source -- {
" Text from tmux
Plug 'wellle/tmux-complete.vim'
" ------------ }
" ---------------------------- }

" --------- Language --------- {
" -- LSP -- {
if g:dynamo_complete_engine ==? 'coc'
  " Not need because coc is LSP client
elseif g:dynamo_complete_engine ==? 'deoplete'
  Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh' }
  let g:LanguageClient_serverCommands={}
  call dynamo#file#RegisterPlugin('languageclient')
endif
" --------- }

" -- Linter -- {
Plug 'dense-analysis/ale'
call dynamo#file#RegisterPlugin('ale')
" ------------ }

" -- Convention -- {
Plug 'editorconfig/editorconfig-vim'
" ---------------- }

" Collection of language packs: syntax, indent ...
Plug 'sheerun/vim-polyglot'
Plug 'Shougo/neco-syntax'

" Syntax for context in file
Plug 'Shougo/context_filetype.vim'

" Load each language
call dynamo#file#LoadLanguagePlugin('markdown')
call dynamo#file#LoadLanguagePlugin('vim')
call dynamo#file#LoadLanguagePlugin('ansible')
call dynamo#file#LoadLanguagePlugin('yaml')
call dynamo#file#LoadLanguagePlugin('ruby')
call dynamo#file#EndLoadPlugin()
" ---------------------------- }
