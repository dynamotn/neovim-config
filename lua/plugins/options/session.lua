local session = require('persisted')

session.setup({
  autosave = true,
  autoload = true,
  use_git_branch = true,
  telescope = {
    before_source = function()
      -- Close all open buffers
      pcall(vim.cmd, 'bufdo bwipeout')
    end,
  },
  branch_separator = '@@',
  allowed_dirs = nil,
})

local present, telescope = pcall(require, 'telescope')

if not present then
  return
end

telescope.load_extension('persisted')
