local present, neorg = pcall(require, 'neorg')

if not present then
  return
end

neorg.setup({
  load = {
    ['core.defaults'] = {},
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
    ['core.norg.concealer'] = {},
    ['core.gtd.base'] = {
      config = {
        workspace = 'personal',
      },
    },
    ['core.integrations.telescope'] = {},
    ['external.kanban'] = {},
    ['external.zettelkasten'] = {},
  },
})
