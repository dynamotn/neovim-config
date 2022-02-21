-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--       General Neovim options      --
---------------------------------------
local opt = vim.opt -- Set options (global/buffer/windows-scoped)
local cmd = vim.cmd -- Execute Vim commands
local exec = vim.api.nvim_exec -- Execute Vimscript

------------ UI ------------- {
-- Status line look nicer
opt.laststatus = 2

-- More natural split opening
opt.splitbelow = true
opt.splitright = true

-- Show shorten messages in UI
opt.shortmess:append('filmnrxoOtT')

-- View specific settings to save and restore view of a file
-- Better Unix / Windows compatibility
opt.viewoptions = 'folds,options,cursor,unix,slash'

-- Enable syntax of file
cmd([[syntax on]])

-- Highlight unwanted space
opt.list = true
opt.listchars = 'tab:→ ,trail:·,extends:↷,precedes:↶'

-- Not show redundant mode line with airline
opt.showmode = false

-- Enable 24 bit RGB colors
opt.termguicolors = true

-- Show current position {
-- Show the line number of all lines
opt.number = true
-- Show the line number relate to current line
opt.relativenumber = true
-- Highlight current line
opt.cursorline = true
------------------------ }
----------------------------- }

---- File manipulation ------ {
-- End of file setting
opt.fileformat = 'unix'

-- Accept modeline of each file
opt.modeline = true
opt.modelines = 1

-- Not save backup
opt.backup = false
opt.writebackup = false
opt.swapfile = false
----------------------------- }

---------- Tweaks ----------- {
-- Highlight matching parenthesis
opt.showmatch = true

-- Don't redraw when using macro
opt.lazyredraw = true

-- Wrap
opt.textwidth = 0
opt.wrapmargin = 0
opt.wrap = true
opt.linebreak = true

-- Flexible backspace
opt.backspace = 'indent,eol,start'

-- Not use mouse
opt.mouse:remove('a')

-- Allow to change terminal's title
opt.title = true

-- Automatically read a file changed outside of vim
opt.autoread = true

-- End of word designator
opt.iskeyword:remove('.#-')

-- Allow the cursor to move just past the end of the line
opt.virtualedit = 'onemore'

-- Timeout of key sequence
opt.timeoutlen = 500

-- Highlight matching parenthesis
opt.showmatch = true

-- Search {
-- Find as you type search
opt.incsearch = true
-- Highlight search terms
opt.hlsearch = true
-- Smart search
opt.smartcase = true
--------- }

-- Indent {
-- Tab tweak
opt.expandtab = true
opt.smarttab = true
opt.shiftwidth = 2
opt.softtabstop = 2
-- Automatically indent
opt.autoindent = true
cmd([[filetype plugin indent on]])
--------- }

-- Size {
-- Command and search max history
opt.history = 50
-- Undo history
opt.undolevels = 50
------- }

-- Folding {
-- Set marker
opt.foldenable = true
opt.foldmethod = 'marker'
opt.foldmarker = '{,}'
-- What movements open folds
opt.foldopen = 'block,hor,mark,percent,quickfix,tag,jump,search,undo'
---------- }
----------------------------- }

------- Autocomplete -------- {
-- Command mode {
opt.wildmenu = true
opt.wildmode = 'list:longest,list:full'
opt.wildignorecase = true
--------------- }

-- Edit mode {
opt.completeopt = 'menu,menuone,preview'
-- Limit completion menu height
opt.pumheight = 15
------------ }
----------------------------- }
