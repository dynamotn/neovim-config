local modules = {
  'global',
  'augroup',
  'command',
}

for _, module in ipairs(modules) do
  local ok, err = pcall(require, 'misc.' .. module)
  if not ok then
    error('Error loading misc.' .. module .. '\n\n' .. err)
  end
end

require('misc.augroup').load_default_augroups()
require('misc.command').start()
