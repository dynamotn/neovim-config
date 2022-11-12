return function(whichkey, bufnr)
  whichkey.register({
    ['<Space>lt'] = {
      function()
        return require('pantran').motion_translate() .. 'aw'
      end,
      'Translate',
      expr = true,
    },
  }, { buffer = bufnr })

  whichkey.register({
    ['<Space>lt'] = { require('pantran').motion_translate, 'Translate', expr = true },
  }, { buffer = bufnr, mode = 'v' })
end
