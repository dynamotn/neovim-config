local present, overseer = pcall(require, 'overseer')

if not present then
  return
end

overseer.setup({})
