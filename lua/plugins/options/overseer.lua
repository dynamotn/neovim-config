local present, overseer = pcall(require, 'overseer')

if not present then
  return
end

overseer.setup({})

vim.api.nvim_create_user_command('OverseerRestart', function()
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    require('overseer.commands')._run_template({ fargs = {} })
  else
    overseer.run_action(tasks[1], 'restart')
  end
end, {})
