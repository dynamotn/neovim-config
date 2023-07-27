local statuscol = require('statuscol')
local builtin = require('statuscol.builtin')

statuscol.setup({
  thousands = '_',
  relculright = true,
  segments = {
    {
      sign = { name = { 'Diagnostic' }, maxwidth = 2, auto = true },
      click = 'v:lua.ScSa',
    },
    { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
    {
      sign = { name = { '.*' }, maxwidth = 2, colwidth = 1, auto = true, wrap = true },
      click = 'v:lua.ScSa',
    },
    {
      text = { builtin.lnumfunc, ' ▏' },
      condition = { true, builtin.not_empty },
      click = 'v:lua.ScLa',
    },
  },
  clickhandlers = {
    FoldOther = false,
  },
})
