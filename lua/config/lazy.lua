-- Install lazy if not exist
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  })
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
local stable = _G.plugin_channel == 'stable'

-- Plugins still developed on their branch but whose newest release is more
-- than two years old (as of 2026-10). `version = '*'` would take them back to
-- that release -- `vim-snippets` to 2014 -- so on `stable` they stay on their
-- branch, the way LazyVim itself treats `nvim-treesitter` and `nvim-cmp`.
-- `optional` keeps a plugin out when nothing else in the spec asks for it.
--
-- `conform.nvim` is here for another reason: its release is younger, but
-- `config.languages` names formatters added since (`gdscript-formatter`), and
-- `scripts/validate-tools.lua` fails on a formatter conform does not know.
-- `nvim-origami` too: its one tag, `v1.9`, is where to pin to keep options
-- it has since dropped, not a release to follow.
local stale_releases = {
  'stevearc/conform.nvim',
  'chrisgrieser/nvim-origami',
  'folke/edgy.nvim',
  'folke/flash.nvim',
  'folke/persistence.nvim',
  'folke/ts-comments.nvim',
  'gbprod/yanky.nvim',
  'gpanders/nvim-parinfer',
  'honza/vim-snippets',
  'johmsalas/text-case.nvim',
  'm00qek/baleia.nvim',
  'marilari88/neotest-vitest',
  'mfussenegger/nvim-jdtls',
  'nvim-lua/plenary.nvim',
  'tpope/vim-dadbod',
  'esensar/nvim-dev-container',
}
local stale_specs = vim.tbl_map(
  function(repo) return { repo, optional = true, version = false } end,
  stable and stale_releases or {}
)
-- Hold a plugin back for a week after a commit or a release, the quarantine
-- the npm, bun, pnpm, uv and Mason sides of these dotfiles already apply. It
-- goes in ahead of `setup`, which installs what is missing as it runs.
require('tools.lazy-quarantine').setup()

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
    {
      -- On `latest`, follow LazyVim's `main` instead of its releases. On
      -- `stable`, repeat LazyVim's own `version = '*'`, so it stays on its
      -- releases.
      --
      -- This cannot be folded into the entry above: LazyVim's own spec sets
      -- `version = '*'`, so an override only sticks if it comes after the
      -- import that pulls that spec in.
      'LazyVim/LazyVim',
      branch = not stable and 'main' or nil,
      version = stable and '*' or false,
    },
    { import = 'plugins.ui' },
    { import = 'plugins.coding' },
    { import = 'plugins.treesitter' },
    { import = 'plugins.lsp' },
    { import = 'plugins.integration' },
    { import = 'plugins.executor' },
    { import = 'plugins.toolbox' },
    { import = 'plugins.lang' },
    stale_specs,
  },
  defaults = {
    lazy = true, -- Lazy loading all plugins
    -- `latest` prefers git commits over tagged releases. With `*`, a plugin
    -- that tags releases follows the newest one, and one that has never
    -- tagged any falls back to its branch, so nothing is left behind. A spec
    -- setting its own `version` or `branch` wins over this either way.
    version = stable and '*' or false,
  },
  -- The channels resolve to different commits, so sharing one lockfile would
  -- have every `:Lazy update` on one channel undo the other's pins.
  lockfile = vim.fn.stdpath('config')
    .. (stable and '/lazy-lock.stable.json' or '/lazy-lock.json'),
  install = { colorscheme = { defaults.colorscheme } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    -- `latest` sees new commits every hour, so a notification would be
    -- noise. A new release on `stable` is rare and worth being told about.
    notify = stable,
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
  dev = {
    path = _G.dev_plugins_path,
    patterns = {},
    -- Without a fallback, a `dev = true` plugin with no checkout under `path`
    -- is treated as a local plugin that is never cloned, so it fails to load
    -- on every machine but the one holding the checkouts. The Lazy UI still
    -- marks the plugins that do come from `path`.
    fallback = true,
  },
  debug = false,
  rocks = {
    enabled = false,
  },
})
