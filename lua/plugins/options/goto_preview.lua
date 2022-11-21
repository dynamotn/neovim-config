local present, goto_preview = pcall(require, 'goto-preview')

if not present then
  return
end

goto_preview.setup({
  default_mappings = false,
})
