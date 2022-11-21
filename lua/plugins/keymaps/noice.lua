vim.keymap.set('n', '<C-f>', function()
  if not require('noice.lsp').scroll(4) then
    return '<C-f>'
  end
end, { silent = true, expr = true })

vim.keymap.set('n', '<C-b>', function()
  if not require('noice.lsp').scroll(-4) then
    return '<C-b>'
  end
end, { silent = true, expr = true })
