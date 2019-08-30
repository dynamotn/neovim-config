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
call dynamo#mapping#Define('nmap', '<leader>', 'w', ':wq<CR>', 'Write and Exit')

" Ctrl+S to same other editor, rarely use
nmap <C-s> :w<CR>
imap <C-s> <Esc>:w<CR>a

" No one is really happy until you have this shortcuts
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qa! qa!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qa qa
" ---------------------------- }

" --------- Window ----------- {
call dynamo#mapping#Group('<Space>', 'w', 'Window')
" Switch between the last two files
call dynamo#mapping#Define('nnoremap', '<Space>', 'ws', '<C-^>', 'Switch buffer')

" Navigate splited window easier
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Layout
call dynamo#mapping#Define('nnoremap', '<Space>', 'w2', ':silent only | vs | wincmd w<CR>', 'Layout 2 columns')
call dynamo#mapping#Define('nnoremap', '<Space>', 'w3', ':silent only | vs | vs | wincmd H<CR>', 'Layout 3 columns')
call dynamo#mapping#Define('nnoremap', '<Space>', 'w=', ':wincmd = <CR>', 'Layout 3 columns')
" ---------------------------- }

" ----------- Tab ------------ {
call dynamo#mapping#Group('<leader>', 't', 'Tab')
" Useful mappings for managing tabs
call dynamo#mapping#Define('map', '<leader>', 'tn', ':tabnew<CR>', 'New tab')
call dynamo#mapping#Define('map', '<leader>', 'to', ':tabonly<CR>', 'Close other tabs')
call dynamo#mapping#Define('map', '<leader>', 'tc', ':tabclose<CR>', 'Close tab')
call dynamo#mapping#Define('map', '<leader>', 'th', ':tabprevious<CR>', 'Previous tab')
call dynamo#mapping#Define('map', '<leader>', 'tl', ':tabnext<CR>', 'Next tab')

" Opens a new tab with the current buffer's path
" Very useful when editing files in the same directory
call dynamo#mapping#Define('map', '<leader>', 'te', ":tabedit <C-r>=expand(\'%:p:h\')<CR>/", 'Tab with current folder')
" ---------------------------- }

" --------- Editing ---------- {
" Automatically add filename or path file
call dynamo#mapping#Group('<leader>', 'f', 'File')
call dynamo#mapping#Define('nnoremap', '<leader>', 'fn', "i<C-r>=expand(\'%:t:n\')<CR>", 'Insert name of file')
call dynamo#mapping#Define('nnoremap', '<leader>', 'fp', "i<C-r>=expand(\'%:p:h\')<CR>", 'Insert path of file')

" Insert new line
map <S-Enter> O<Esc>
map <Enter> o<Esc>

" Change indentation with multiple level
vnoremap < <gv
vnoremap > >gv
" ---------------------------- }

" -------- Navigation -------- {
call dynamo#mapping#Group('<Space>', 'f', 'File')
" ---------------------------- }

" ------------ Git ----------- {
" Move to hunks
call dynamo#mapping#Group('<Space>', 'g', 'Git')
" ---------------------------- }

" --------- Language --------- {
call dynamo#mapping#Group('<Space>', 'l', 'Language')
" ---------------------------- }