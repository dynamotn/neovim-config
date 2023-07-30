return {
  -- For gentoo filetypes
  vim.fn.system('grep -is "Gentoo" /etc/os-release') ~= '' and {
      'gentoo/gentoo-syntax',
    } or nil,
}
