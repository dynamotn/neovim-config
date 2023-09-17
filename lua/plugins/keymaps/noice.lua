return {
  {
    '<C-f>',
    function()
      if not require('noice.lsp').scroll(4) then
        return '<C-f>'
      end
    end,
    desc = 'Signature scroll forward',
  },
  {
    '<C-b>',
    function()
      if not require('noice.lsp').scroll(-4) then
        return '<C-b>'
      end
    end,
    desc = 'Signature scroll backward',
  },
}
