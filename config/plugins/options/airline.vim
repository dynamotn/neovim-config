" vim:foldmethod=marker:foldmarker={,}
" Use Powerline fonts
let g:airline_powerline_fonts=1

" Set theme
if has('termguicolors')
  call dynamo#time#AutoDayNight("let g:airlinetheme='papercolor'", "let g:airlinetheme='one'")
else
  let g:airline_theme='hybridline'
endif

" Preview window should be excluded
let g:airline_exclude_preview=1

" Git branch
let g:airline#extensions#branch#empty_message=''
let g:airline#extensions#branch#format=2

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
