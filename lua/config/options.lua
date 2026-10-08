local opt = vim.opt
local g = vim.g

g.mapleader = ' '
g.maplocalleader = '\\'

g.autoformat = true -- Format on save, see `util.format`
g.snacks_animate = true
-- Copilot's native inline completions cannot be completion items, so blink
-- leaves the ghost text to them. Set here, ahead of the blink spec reading it.
g.ai_cmp = false
-- Root detection for `util.root`: detector names, root markers, or functions
g.root_spec = { 'lsp', { '.git', 'lua' }, 'cwd' }
g.root_lsp_ignore = { 'copilot' } -- LSP clients whose root is never used
g.deprecation_warnings = false
g.trouble_lualine = true -- Document symbols from Trouble in lualine
g.markdown_recommended_style = 0 -- Keep markdown indentation settings

opt.autowrite = true
-- Not over SSH, where the OSC 52 integration takes over
opt.clipboard = vim.env.SSH_CONNECTION and '' or 'unnamedplus'
opt.completeopt = 'menu,menuone,noselect'
opt.conceallevel = 2 -- Hide * markup for bold and italic
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true
opt.expandtab = true
opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}
opt.foldlevel = 99
opt.foldmethod = 'indent'
opt.foldtext = ''
opt.formatexpr = "v:lua.require'util.format'.formatexpr()"
opt.formatoptions = 'jcroqlnt'
opt.grepformat = '%f:%l:%c:%m'
opt.grepprg = 'rg --vimgrep'
opt.ignorecase = true
opt.inccommand = 'nosplit' -- Preview incremental substitute
opt.jumpoptions = 'view'
opt.laststatus = 3 -- Global statusline
opt.linebreak = true -- Wrap lines at convenient points
opt.list = true -- Show some invisible characters
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.ruler = false
opt.scrolloff = 4
opt.sessionoptions = {
  'buffers',
  'curdir',
  'tabpages',
  'winsize',
  'help',
  'globals',
  'skiprtp',
  'folds',
}
opt.shiftround = true
opt.shiftwidth = 2
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- The statusline shows it
opt.sidescrolloff = 8
opt.signcolumn = 'yes' -- Always there, so the text does not shift
opt.smartcase = true
opt.smartindent = true
opt.smoothscroll = true
opt.splitbelow = true
opt.splitkeep = 'screen'
opt.splitright = true
opt.statuscolumn = "%!v:lua.require'util.plugin'.statuscolumn()"
opt.tabstop = 2
opt.termguicolors = true
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Quick to trigger which-key
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.virtualedit = 'block'
opt.wildmode = 'longest:full,full'
opt.winminwidth = 5

opt.guifont = 'Iosevka Dynamo:h11' -- Font for GUI
opt.listchars = 'tab:→ ,trail:·,extends:↷,precedes:↶' -- Highlight unwanted space
opt.fileencoding = 'utf-8'
opt.fileformat = 'unix'
opt.modeline = true -- Accept modeline of each file
opt.modelines = 2
opt.backup = true -- Enable backup
-- `//`: named after the whole path, so `init.lua~` of two directories differ
opt.backupdir = vim.fn.stdpath('state') .. '/backup//'
opt.showmatch = true -- Highlight matching parenthesis
opt.backspace = 'indent,eol,start' -- Flexible backspace
opt.mouse = '' -- Not use mouse
opt.title = true -- Allow to change terminal's title
opt.autoread = true -- Automatically read a file changed outside of vim
opt.colorcolumn = '80,120' -- 80, 120 column chars line length
opt.wrap = true -- Set wrap mode
opt.spelllang = { 'en_us', 'vi', 'proper', 'technical' } -- My spell list

-- Resolve the background before any plugin loads, so the colorscheme comes up
-- in the right half of the day rather than flipping once it is on screen.
require('util.day_night').init()

-- Disable non-Lua provider
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0

-- Setup abbreviations. They expand in prose only -- a prose filetype, or a
-- comment of code -- so `gh pr create` in a script or `CC = cc` in a Makefile
-- are left as typed.
local prose = {
  codecompanion = true,
  gitcommit = true,
  markdown = true,
  octo = true,
  text = true,
}
local function in_prose()
  if prose[vim.bo.filetype] then return true end
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local ok, captures =
    pcall(vim.treesitter.get_captures_at_pos, 0, row - 1, math.max(col - 1, 0))
  for _, capture in ipairs(ok and captures or {}) do
    if capture.capture:find('^comment') then return true end
  end
  return false
end
local abbreviations = require('config.defaults').abbreviations
for abbr, full_text in pairs(abbreviations) do
  vim.keymap.set(
    'ia',
    abbr,
    function() return in_prose() and full_text or abbr end,
    { expr = true, desc = full_text }
  )
end
