local opt = vim.opt
local g = vim.g

g.mapleader = ' '
g.maplocalleader = '\\'

g.autoformat = true -- Format on save, see `util.format`
g.snacks_animate = true
g.ai_cmp = true -- AI suggestions through the completion menu, not inline
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
opt.backupdir = vim.fn.stdpath('state') .. '/backup'
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

-- Setup abbreviations
local abbreviations = require('config.defaults').abbreviations
for abbr, full_text in pairs(abbreviations) do
  vim.cmd.inoreabbrev(abbr, full_text)
end

-- Setup project config with `.nvim` folder in project root
--
-- The folder goes on the runtimepath, so whatever sits in its `plugin/` runs
-- on its own, and that is code belonging to whichever repository happens to be
-- open. So it passes through the same trust database as `exrc`: the folder is
-- added once it has been trusted, and Neovim asks otherwise. `:trust` takes
-- the decision back. Trust on a directory goes by name rather than contents,
-- so it also covers files put there later.
---@type string? Folder currently on the runtimepath
local project_rtp
---@type table<string, boolean> Verdict per folder, kept for the session so
--- that walking back into a project neither asks again nor loses its folder
local trusted_rtp = {}

---@param directory string
---@return boolean
local function is_trusted(directory)
  if trusted_rtp[directory] == nil then
    -- `vim.secure.read` blocks on its prompt and goes on handling events while
    -- it waits, so the verdict is pinned before the question is put: without
    -- it a second pass arrives mid-prompt, finds nothing recorded yet, and
    -- asks about the same folder all over again.
    trusted_rtp[directory] = false
    trusted_rtp[directory] = vim.fn.isdirectory(directory) == 1
      and vim.secure.read(directory) ~= nil
  end
  return trusted_rtp[directory]
end

local function setup_project_rtp()
  local directory = require('util.root').get() .. '/.nvim'
  if directory == project_rtp then return end
  if project_rtp then
    vim.opt.rtp:remove(project_rtp)
    project_rtp = nil
  end
  if is_trusted(directory) then
    vim.opt.rtp:append(directory)
    project_rtp = directory
  end
end

setup_project_rtp()
-- The root follows the working directory, so it is worth another look whenever
-- that moves, instead of being settled once at startup. `util.root` drops its
-- cached root from a handler of this very event, so the fresh one is only
-- there once the event has been dealt with.
vim.api.nvim_create_autocmd('DirChanged', {
  group = vim.api.nvim_create_augroup('dy_project_rtp', { clear = true }),
  callback = function() vim.schedule(setup_project_rtp) end,
})
