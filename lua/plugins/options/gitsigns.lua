local present, gitsigns = pcall(require, 'gitsigns')

if not present then
  return
end

gitsigns.setup({})
