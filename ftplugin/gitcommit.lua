vim.opt_local.wrap = true
vim.opt_local.spell = true
-- The message from the staged diff (`tools.ai.commit`), never from this
-- buffer, which AI is kept away from
vim.keymap.set(
  'n',
  '<localleader>g',
  function() require('tools.ai.commit').write() end,
  { buffer = true, desc = 'Write Commit Message (AI)' }
)
