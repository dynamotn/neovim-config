return {
  -- Edit chezmoi managed files
  {
    import = 'lazyvim.plugins.extras.util.chezmoi',
    enabled = _G.used_full_plugins or _G.enabled_plugins.chezmoi,
  },
  -- Disable unused plugin
  { 'alker0/chezmoi.vim', enabled = false },
}
