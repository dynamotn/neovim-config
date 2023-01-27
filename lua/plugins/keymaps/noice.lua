local noice_lsp = require('noice.lsp')

return {
  {
    '<C-f>',
    function()
      if not noice_lsp.scroll(4) then
        return '<C-f>'
      end
    end,
    desc = 'Signature scroll forward',
  },
  {
    '<C-b>',
    function()
      if not noice_lsp.scroll(-4) then
        return '<C-b>'
      end
    end,
    desc = 'Signature scroll backward',
  },
}
