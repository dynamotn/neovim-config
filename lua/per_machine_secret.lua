_G.firenvim_site_settings = vim.tbl_extend('force', _G.firenvim_site_settings, {
  [ [[.*.fsoft\.com\.vn.*]] ] = {
    priority = 9,
    takeover = 'never',
  },
})
