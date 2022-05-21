local present, gps = pcall(require, 'nvim-gps')

if not present then
  return
end

gps.setup({})
