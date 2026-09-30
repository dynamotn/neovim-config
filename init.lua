-- Globals shared across the configuration, with their defaults and types
require('config.globals')

local version = '0.13.0'
if vim.fn.has('nvim-' .. version) == 1 then
  -- Load specific configurations per machine
  require('per_machine')
  -- Load LazyVim
  require('config.lazy')
else
  vim.api.nvim_err_writeln(
    'Neovim ' .. version .. ' or higher is required. Please update Neovim.'
  )
end
