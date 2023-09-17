local modules = {
  'debug',
  'bootstrap',
  'options',
  'keymaps',
  'filetype',
  'highlight',
}

for _, module in ipairs(modules) do
  local ok, err = pcall(require, 'core.' .. module)
  if not ok then
    error('Error loading core.' .. module .. '\n\n' .. err)
  end
end
