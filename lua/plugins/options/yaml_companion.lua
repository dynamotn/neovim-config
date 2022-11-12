local present, yaml_companion = pcall(require, 'yaml-companion')

if not present then
  return
end

yaml_companion.setup({})

local present, telescope = pcall(require, 'telescope')

if not present then
  return
end

telescope.load_extension('yaml_schema')
