local modules = {
  'global',
}

for _, module in ipairs(modules) do
  local ok, err = pcall(require, 'misc.' .. module)
  if not ok then
    error('Error loading misc.' .. module .. '\n\n' .. err)
  end
end
