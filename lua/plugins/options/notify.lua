local present, notify = pcall(require, 'notify')

if not present then
  return
end

notify.setup({
  background_colour = '#000000',
})

vim.notify = notify
