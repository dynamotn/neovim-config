return function(whichkey, bufnr)
  whichkey.register({
    ['<Space>xo'] = { require('open').open_cword, 'Open with tool' },
  }, { buffer = bufnr })
end
