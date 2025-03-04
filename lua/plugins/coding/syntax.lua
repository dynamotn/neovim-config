return {
  {
    -- For gentoo filetypes
    'gentoo/gentoo-syntax',
    enabled = _G.is_gentoo or _G.used_full_plugins,
  },
}
