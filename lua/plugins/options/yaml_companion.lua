local yaml_companion = require('yaml-companion')

yaml_companion.setup({})

local present, telescope = pcall(require, 'telescope')

if not present then
  return
end

telescope.load_extension('yaml_schema')
