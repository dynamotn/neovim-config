local present, gitsigns = pcall(require, 'gitsigns')

if not present then
  return
end

gitsigns.setup({
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text_pos = 'right_align',
  },
})
