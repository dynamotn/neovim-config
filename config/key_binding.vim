" vim:foldmethod=marker:foldmarker={,}
" ---------- Base ------------ {
" Habit
let g:mapleader='\'

" Need help, but I can type on my own
noremap <F1> <Esc>

" Copy paste, stackoverflow =]]
set pastetoggle=<F3>

" Load config and install plugin
nmap <C-i> :source $MYVIMRC<CR>:PlugInstall<CR>
" ---------------------------- }

" ------ Save and Exit ------- {
" Root permission
cmap w!! w ! sudo tee % > /dev/null

" Write the current file and exit
nmap <leader>w :wq<CR>

" Ctrl+S to same other editor, rarely use
nmap <C-s> :w<CR>
imap <C-s> <Esc>:w<CR>a

" No one is really happy until you have this shortcuts
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall
" ---------------------------- }

" --------- Window ----------- {
" Switch between the last two files
nnoremap <leader><leader> <C-^>

" Navigate splited window easier
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
" ---------------------------- }

" ----------- Tab ------------ {
" Useful mappings for managing tabs
map <leader>tn :tabnew<CR>
map <leader>to :tabonly<CR>
map <leader>tc :tabclose<CR>
map <leader>tm :tabmove
map <leader>th :tabprevious<CR>
map <leader>tl :tabnext<CR>

" Opens a new tab with the current buffer's path
" Very useful when editing files in the same directory
map <leader>te :tabedit <C-r>=expand("%:p:h")<CR>/
" ---------------------------- }

" --------- Editing ---------- {
" Automatically add filename or path file
inoremap <leader>fn <C-r>=expand("%:t:r")<CR>
inoremap <leader>fp <C-r>=expand("%:p:h")<CR>

" Insert new line
map <S-Enter> O<Esc>
map <Enter> o<Esc>

" Change indentation with multiple level
vnoremap < <gv
vnoremap > >gv
" ---------------------------- }

" --------- Airline ---------- {
" Switch tab
for i in range(1,9)
  exec 'nmap <leader>' . i . ' <Plug>AirlineSelectTab' . i
endfor
nmap <leader>- <Plug>AirlineSelectPrevTab
nmap <leader>+ <Plug>AirlineSelectNextTab
" ---------------------------- }
