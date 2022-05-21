local present, playground = pcall(require, 'nvim-treesitter-playground')

if not present then
  return
end

require('nvim-treesitter.configs').setup({
  playground = {
    enable = true,
  },
})
