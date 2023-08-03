return {
  {
    -- For gentoo filetypes
    'gentoo/gentoo-syntax',
    cond = vim.fn.system('grep -is "Gentoo" /etc/os-release') ~= '',
  },
}
