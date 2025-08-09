-- local util = require('lspconfig.util')

return {
  cmd = { 'termux-language-server' },
  filetypes = {
    -- Android Termux
    'sh.build', -- build.sh
    'sh.subpackage', -- *.subpackage.sh
    -- ArchLinux/Windows Msys2
    'sh.PKGBUILD', -- PKGBUILD
    'sh.install', -- *.install
    'sh.makepkg.conf', -- makepkg.conf
    -- Gentoo
    'sh.ebuild', -- *.ebuild
    'sh.eclass', -- *.eclass
    'sh.make.conf', -- /etc/make.conf, /etc/portage/make.conf
    'sh.color.map', -- /etc/portage/color.map
    -- Zsh
    'sh.mdd', -- *.mdd
  },
  root_markers = {
    'build.sh',
    'PKGBUILD',
    'makepkg.conf',
    'make.conf',
    '.git',
  },
}
