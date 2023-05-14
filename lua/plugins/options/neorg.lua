local neorg = require('neorg')

neorg.setup({
  load = {
    ['core.defaults'] = {},
    ['core.norg.esupports.hop'] = {},
    ['core.norg.esupports.indent'] = {},
    ['core.norg.journal'] = {},
    ['core.norg.qol.todo_items'] = {},
    ['core.syntax'] = {},
    ['core.neorgcmd'] = {},
    ['core.norg.concealer'] = {},
    ['core.norg.dirman'] = {
      config = {
        workspaces = {
          personal = '~/Notes/personal',
          enterprise = '~/Notes/enterprise',
          freelance = '~/Notes/freelance',
        },
        autochdir = true,
        index = 'dynamo.norg',
      },
    },
    ['core.norg.completion'] = {
      config = {
        engine = 'nvim-cmp',
      },
    },
    ['core.integrations.nvim-cmp'] = {},
    ['core.integrations.telescope'] = {},
    ['external.zettelkasten'] = {},
  },
})
