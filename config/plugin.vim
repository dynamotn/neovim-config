" vim:foldmethod=marker:foldmarker={,}
" ------- Color scheme ------- {
Plug 'w0ng/vim-hybrid'
  let g:hybrid_custom_term_colors=1
  let g:hybrid_reduced_contrast=1
" ---------------------------- }

" -------- Eyecandy ---------- {
" -- General GUI -- {
Plug 'vim-airline/vim-airline'
  " Use Powerline fonts
  let g:airline_powerline_fonts=1

  " Set theme
  let g:airline_theme='hybridline'

  " Preview window should be excluded
  let g:airline_exclude_preview=1

  " -- Tabline -- {
  " Enable
  let g:airline#extensions#tabline#enabled=1
  " Not show buffer, easy to view tab number
  let g:airline#extensions#tabline#show_buffers=0
  " Show file name of split view at top right
  let g:airline#extensions#tabline#show_splits=1
  " Show current file name of each tab at top left
  let g:airline#extensions#tabline#show_tabs=1
  " Show tab number
  let g:airline#extensions#tabline#show_tab_nr=1
  let g:airline#extensions#tabline#show_tab_type=1
  let g:airline#extensions#tabline#tab_nr_type=1
  let g:airline#extensions#tabline#tabs_label='Tabs'
  " Show fullpath of filename
  let g:airline#extensions#tabline#fnamecollapse=0
  " Not need to show X button
  let g:airline#extensions#tabline#show_close_button=0
  " ------------- }

  " -- Status bar -- {
  " Show encoding and buffer number
  let g:airline_section_y='BN: %{bufnr("%")} %{&fileencoding} %{&ff}'
  "                                 |               |            |
  "                                 |               |            +-- File format
  "                                 |               +--------------- File encoding
  "                                 +------------------------------- Buffer number
  " Simple show position
  let g:airline_section_z='%2p%% %2l/%L:%2v'
  "                          |     |  |   |
  "                          |     |  |   +-- Current column
  "                          |     |  +------ Number of lines
  "                          |     +--------- Current line
  "                          +--------------- Current % into file
  " ---------------- }
" ----------------- }
" ---------------------------- }

" --------- Terminal --------- {
if v:version >= 800
  Plug 'Shougo/deol.nvim'
else
  Plug 'Shougo/vimshell.vim' | Plug 'Shougo/vimproc.vim', {'do' : 'make'}
endif
" ---------------------------- }

" ---------- Guide ----------- {
Plug 'hecal3/vim-leader-guide'
  " Base SPACE menu
  let g:guide_space_map={}

  " Base leader menu
  let g:guide_leader_map={}

  " All menus
  let g:guide_map={}
  let g:guide_map[' ']=g:guide_space_map
  let g:guide_map[' ']['name']='Space'
  let g:guide_map[get(g:, 'mapleader', '\')]=g:guide_leader_map
  let g:guide_map[get(g:, 'mapleader', '\')]['name']='Leader'
" ---------------------------- }

" ---------- Window ---------- {
" Interactive choose window
Plug 't9md/vim-choosewin'
" ---------------------------- }
