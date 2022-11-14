local present, neotree = pcall(require, 'neo-tree')

if not present then
  return
end

neotree.setup({})
