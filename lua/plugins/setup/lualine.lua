vim.g.lualine_laststatus = vim.o.laststatus
if vim.fn.argc(-1) > 0 then
  -- set an empty statusline till lualine loads
  vim.o.statusline = " "
else
  -- hide the statusline on the starter page
  vim.o.laststatus = 0
end
