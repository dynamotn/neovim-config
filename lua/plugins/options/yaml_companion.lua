local yaml_companion = require('yaml-companion')

yaml_companion.setup({
  schemas = {
    {
      name = 'Flux',
      uri = 'https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/all.json',
    },
  },
})

local present, telescope = pcall(require, 'telescope')

if not present then
  return
end

telescope.load_extension('yaml_schema')
