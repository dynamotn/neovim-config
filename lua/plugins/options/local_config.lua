local present, local_config = pcall(require, 'config-local')

if not present then
  return
end

local_config.setup({
  config_files = { '.nvimrc.lua', '.nvimrc' },
})
