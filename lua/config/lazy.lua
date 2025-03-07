-- Install lazy if not exist
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
-- Load lazy to runtime path
vim.opt.rtp:prepend(lazypath)

local defaults = require('config.defaults')
-- Setup lazy
require('lazy').setup({
  spec = {
    {
      'LazyVim/LazyVim',
      import = 'lazyvim.plugins',
      opts = {
        colorscheme = defaults.colorscheme,
        news = {
          lazyvim = true,
        },
        icons = defaults.icons,
      },
    },
    { import = 'plugins.ui' },
    { import = 'plugins.coding' },
    { import = 'plugins.treesitter' },
    { import = 'plugins.lsp' },
    { import = 'plugins.integration' },
    { import = 'plugins.executor' },
    { import = 'plugins.toolbox' },
    { import = 'plugins.lang' },
  },
  defaults = {
    lazy = true, -- Lazy loading all plugins
  },
  install = { colorscheme = { defaults.colorscheme } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        'gzip',
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
  ui = {
    custom_keys = {
      ['<localleader>d'] = function(plugin) dd(plugin) end,
    },
  },
  debug = false,
})
