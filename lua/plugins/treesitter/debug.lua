return {
  {
    -- Debug Treesitter
    'nvim-treesitter/playground',
    dependencies = { 'nvim-treesitter' },
    cmd = 'TSPlaygroundToggle',
    enabled = _G.used_full_plugins,
  },
}
