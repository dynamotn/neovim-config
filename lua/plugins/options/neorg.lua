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
          work = '~/Notes/work',
          idea = '~/Notes/idea',
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
    ['core.norg.concealer'] = {},
    ['core.gtd.base'] = {
      config = {
        workspace = 'idea',
      },
    },
    ['core.integrations.telescope'] = {},
    ['external.kanban'] = {},
  },
})
