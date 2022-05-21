local present, surround = pcall(require, 'surround')

if not present then
  return
end

surround.setup({
  mappings_style = 'surround',
})
