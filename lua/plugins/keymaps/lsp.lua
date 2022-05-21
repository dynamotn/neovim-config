return function(whichkey, bufnr)
  whichkey.register({
    ['gi'] = { '<cmd>lua vim.lsp.buf.implementation()<CR>', 'Go to implementation' },
    ['gt'] = { '<cmd>lua vim.lsp.buf.type_definition()<CR>', 'Go to type definition' },
    ['gr'] = { '<cmd>lua vim.lsp.buf.references()<CR>', 'Go to references' },
    ['<Space>ff'] = { '<cmd>lua vim.lsp.buf.formatting()<CR>', 'File formatting' },
  }, { buffer = bufnr })

  whichkey.register({
    ['<Space>ff'] = { '<cmd>lua vim.lsp.buf.range_formatting()<CR>', 'File formatting with range' },
  }, { buffer = bufnr, mode = 'v' })
end
