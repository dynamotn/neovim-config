local neorg = require('neorg')

neorg.setup({
  load = {
    ['core.defaults'] = {},
    ['core.esupports.metagen'] = {
      config = {
        type = 'auto',
        update_date = true,
      },
    },
    ['core.journal'] = {
      config = {
        workspace = 'personal',
        strategy = 'flat',
      },
    },
    ['core.syntax'] = {},
    ['core.neorgcmd'] = {},
    ['core.concealer'] = { config = { icon_preset = 'diamond' } },
    ['core.dirman'] = {
      config = {
        workspaces = {
          personal = '~/Notes/personal',
          enterprise = '~/Notes/enterprise',
          freelance = '~/Notes/freelance',
        },
        index = 'index.norg',
      },
    },
    ['core.completion'] = {
      config = {
        engine = 'nvim-cmp',
      },
    },
    ['core.highlights'] = {},
    ['core.ui.calendar'] = {},
    ['core.integrations.nvim-cmp'] = {},
    ['core.integrations.telescope'] = {},
    ['core.integrations.treesitter'] = {
      config = {
        configure_parsers = true,
        install_parsers = false,
      },
    },
    ['core.fs'] = {},
  },
})
