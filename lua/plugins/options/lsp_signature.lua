local present, lsp_signature = pcall(require, 'lsp_signature')

if not present then
  return
end

lsp_signature.setup({
  bind = true,
  handler_opts = {
    border = 'rounded',
  },
  zindex = 50,
  check_completion_visible = true,
})
