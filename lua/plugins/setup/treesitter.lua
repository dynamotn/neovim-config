require('lazy').load({ plugins = 'treesitter', wait = true })
require('nvim-treesitter.install').update({ with_sync = true })()
