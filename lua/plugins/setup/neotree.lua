if vim.fn.argc() == 1 then
  local stat = vim.loop.fs_stat(vim.fn.argv(0))
  if stat and stat.type == 'directory' then
    require('lazy').load({ plugins = { 'neotree' } })
    require('neo-tree').show(nil, true, true, true)
  end
end
