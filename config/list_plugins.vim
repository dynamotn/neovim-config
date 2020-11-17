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
call dynamo#plugin#Register('colorscheme')
" ---------------------------- }

" --------- Eyecandy --------- {
" -- Status line -- {
Plug 'vim-airline/vim-airline'
call dynamo#plugin#Register('airline')
" ----------------- }

" -- Startup screen -- {
Plug 'mhinz/vim-startify'
call dynamo#plugin#Register('startify')
" -------------------- }

" -- Text -- {
if has('termguicolors') && executable('go')
  Plug 'RRethy/vim-hexokinase', { 'do': 'make hexokinase' }
  call dynamo#plugin#Register('hexokinase')
elseif v:version >= 800
  Plug 'chrisbra/Colorizer'
  call dynamo#plugin#Register('colorizer-nvim')
else
  Plug 'lilydjwg/colorizer'
  call dynamo#plugin#Register('colorizer-vim')
endif
" ---------- }

" -- Icon -- {
Plug 'ryanoasis/vim-devicons'
" ---------- }

" -- Indent -- {
if v:version >= 702
  Plug 'nathanaelkane/vim-indent-guides'
  call dynamo#plugin#Register('indent_guide')
end
" ------------ }

" -- Parentheses -- {
Plug 'luochen1990/rainbow'
call dynamo#plugin#Register('rainbow')
" ----------------- }

" -- Mark -- {
if has('signs')
  Plug 'kshenoy/vim-signature'
  call dynamo#plugin#Register('signature')
endif
" ---------- }
"
" -- Space -- {
Plug 'ntpeters/vim-better-whitespace'
call dynamo#plugin#Register('better_whitespace')
" ----------- }
" ---------------------------- }

" --------- Terminal --------- {
if v:version >= 800
  Plug 'Shougo/deol.nvim', { 'on': 'Deol' }
  call dynamo#plugin#Register('deol')
else
  Plug 'Shougo/vimshell.vim', { 'on': 'VimShell' } | Plug 'Shougo/vimproc.vim', { 'do' : 'make', 'on': 'VimShell' }
  call dynamo#plugin#Register('vimshell')
endif
" ---------------------------- }

" --------- Framework -------- {
" Guide
Plug 'liuchengxu/vim-which-key'
call dynamo#plugin#Register('which_key')
" ---------------------------- }

" -------- Navigation -------- {
" -- Window -- {
" Interactive choose window
Plug 't9md/vim-choosewin', { 'on': '<Plug>(choosewin)' }
call dynamo#plugin#Register('choosewin')
" ------------ }

" -- File explorer -- {
Plug 'scrooloose/nerdtree' | Plug 'Xuyuanp/nerdtree-git-plugin'
call dynamo#plugin#Register('nerdtree')
" ------------------- }
" ---------------------------- }

" -------- Efficiency -------- {
" Show tags and LSP symbols
if executable('ctags')
  if v:version >= 800
    Plug 'liuchengxu/vista.vim'
    call dynamo#plugin#Register('vista')
  else
    Plug 'majutsushi/tagbar'
    call dynamo#plugin#Register('tagbar')
  endif
endif

" Automatically update tags
Plug 'craigemery/vim-autotag'

" Fast comment
if v:version >= 700
  Plug 'scrooloose/nerdcommenter'
  call dynamo#plugin#Register('nerdcommenter')
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
call dynamo#plugin#Register('test')

" Alignment
Plug 'junegunn/vim-easy-align'
call dynamo#plugin#Register('easy_align')

" Fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } | Plug 'junegunn/fzf.vim'
" Yank history
Plug 'Shougo/neoyank.vim' | Plug 'justinhoward/fzf-neoyank'
call dynamo#plugin#Register('fzf')

" Table mode formatter
Plug 'dhruvasagar/vim-table-mode', { 'on': ['TableModeEnable', 'TableModeToggle'] }

Plug 'tyru/open-browser-github.vim' | Plug 'tyru/open-browser.vim'
call dynamo#plugin#Register('open_browser')
" ---------------------------- }

" ----------- VCS ------------ {
" Show hunks at ruler
if has('signs')
  Plug 'mhinz/vim-signify'
endif

" Wrapper tool for Git
Plug 'tpope/vim-fugitive' | Plug 'junegunn/gv.vim'
call dynamo#plugin#Register('git')
" ---------------------------- }

" -------- Completion -------- {
" -- Code -- {
" Engine
if executable('node') && executable('yarn') && (v:version >= 800 && !has('nvim')) || has('nvim-0.3.1')
  Plug 'neoclide/coc.nvim', { 'branch': 'release' }
  call dynamo#plugin#Register('coc')
endif
if !dynamo#misc#HasEngine() && v:version >= 800 && has('python3') && has('timers') && g:dynamo_python3_version >= 306.01
  let plug_param_for_deoplete={ 'do': 'UpdateRemotePlugins' }
  if !has('nvim-0.3')
    let plug_param_for_deoplete.tag='4.1'
  endif
  Plug 'Shougo/deoplete.nvim', plug_param_for_deoplete
  call dynamo#plugin#Register('deoplete')
endif
if !dynamo#misc#HasEngine() || (v:version >= 703 && has('lua'))
  Plug 'Shougo/neocomplete.vim'
  call dynamo#plugin#Register('neocomplete')
endif
" ---------- }

" -- Snippet -- {
" Engine
if v:version >= 704
  Plug 'Shougo/neosnippet'
  call dynamo#plugin#Register('neosnippet')
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
  call dynamo#plugin#Register('languageclient')
endif
" --------- }

" -- Linter -- {
Plug 'dense-analysis/ale'
call dynamo#plugin#Register('ale')
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
call dynamo#plugin#LoadLanguage('markdown')
call dynamo#plugin#LoadLanguage('vim')
call dynamo#plugin#LoadLanguage('ansible')
call dynamo#plugin#LoadLanguage('yaml')
call dynamo#plugin#LoadLanguage('ruby')
call dynamo#plugin#LoadLanguage('terraform')
call dynamo#plugin#EndLoad()
" ---------------------------- }
