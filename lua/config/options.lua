local opt = vim.opt
local g = vim.g

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
opt.mouse:remove('a') -- Not use mouse
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
  local directory = require('lazyvim.util.root').get() .. '/.nvim'
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
-- that moves, instead of being settled once at startup. LazyVim drops its
-- cached root from a handler of this very event, so the fresh one is only
-- there once the event has been dealt with.
vim.api.nvim_create_autocmd('DirChanged', {
  group = vim.api.nvim_create_augroup('dy_project_rtp', { clear = true }),
  callback = function() vim.schedule(setup_project_rtp) end,
})
