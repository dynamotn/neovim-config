local present, lightbulb = pcall(require, 'nvim-lightbulb')

if not present then
  return
end

lightbulb.setup({
  autocmd = {
    enabled = true,
  },
})
