local present, navic = pcall(require, 'nvim-navic')

if not present then
  return
end

navic.setup({})
