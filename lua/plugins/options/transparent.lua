local present, transparent = pcall(require, 'transparent')

if not present then
  return
end

transparent.setup({
  enable = true,
})
