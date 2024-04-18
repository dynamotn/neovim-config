-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--       General Neovim options      --
---------------------------------------
local opt = vim.opt -- Set options (global/buffer/windows-scoped)

------------ UI ------------- {
-- Status line look nicer
opt.laststatus = 3

-- More natural split opening
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = 'screen'

-- Show shorten messages in UI
opt.shortmess:append('filmnrxoOtT')

-- View specific settings to save and restore view of a file
-- Better Unix / Windows compatibility
opt.viewoptions = 'folds,options,cursor,unix,slash'

-- Highlight unwanted space
opt.list = true
opt.listchars = 'tab:→ ,trail:·,extends:↷,precedes:↶'

-- Not show redundant mode line with airline
opt.showmode = false

-- Enable 24 bit RGB colors
opt.termguicolors = true

-- Lines and columns of context
opt.scrolloff = 10
opt.sidescrolloff = 10

-- Smooth scroll
if vim.fn.has("nvim-0.10") == 1 then
  opt.smoothscroll = true
end

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
-- Encoding
opt.fileencoding = 'utf-8'

-- End of file setting
opt.fileformat = 'unix'

-- Accept modeline of each file
opt.modeline = true
opt.modelines = 2

-- Not save backup
opt.backup = false
opt.writebackup = false
opt.swapfile = false
----------------------------- }

---------- Tweaks ----------- {
opt.cp = false

-- Highlight matching parenthesis
opt.showmatch = true

-- Wrap
opt.textwidth = 0
opt.wrapmargin = 0
opt.wrap = false
opt.linebreak = true

-- Flexible backspace
opt.backspace = 'indent,eol,start'

-- Not use mouse
opt.mouse:remove('a')

-- Sync with system clipboard
if not vim.env.SSH_TTY then
  opt.clipboard = 'unnamedplus'
end

-- Allow to change terminal's title
opt.title = true

-- Automatically read a file changed outside of vim
opt.autoread = true

-- End of word designator
opt.iskeyword:remove('.#-')

-- Allow the cursor to move just past the end of the line
opt.virtualedit = 'onemore'

-- Timeout of key sequence
opt.timeoutlen = 200

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
opt.smartindent = true
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
opt.foldcolumn = '1'
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmarker = '{,}'
opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}
-- What movements open folds
opt.foldopen = 'block,hor,mark,percent,quickfix,tag,jump,search,undo'
---------- }

-- Session
opt.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal'

-- Allow project local config
opt.exrc = true
----------------------------- }

------- Autocomplete -------- {
-- Command mode {
opt.wildmenu = true
opt.wildmode = 'list:longest,list:full'
opt.wildignorecase = true
--------------- }

-- Edit mode {
opt.completeopt = 'menu,menuone,noselect'
-- Limit completion menu height
opt.pumheight = 15
------------ }
----------------------------- }
