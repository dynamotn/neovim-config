local statuscol = require('statuscol')
local builtin = require('statuscol.builtin')

statuscol.setup({
  thousands = '_',
  relculright = true,
  ft_ignore = {
    'sagaoutline',
  },
  segments = {
    { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
    {
      text = { builtin.lnumfunc, ' ' },
      condition = { true, builtin.not_empty },
      click = 'v:lua.ScLa',
    },
    {
      text = { '%s' },
      sign = { name = { '.*' }, maxwidth = 2, colwidth = 1, auto = true, wrap = true },
      click = 'v:lua.ScSa',
    },
  },
  clickhandlers = {
    FoldOther = false,
  },
})
