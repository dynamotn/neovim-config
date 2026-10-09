-- The preview loads `tools.diagram.d2.snacks` on the key, not with the buffer
vim.keymap.set(
  'n',
  '<leader>cp',
  function() require('tools.diagram.d2.snacks').preview(0) end,
  { buffer = true, desc = 'Preview D2 diagram' }
)
