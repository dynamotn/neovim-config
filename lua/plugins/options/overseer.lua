local present, overseer = pcall(require, 'overseer')

if not present then
  return
end

overseer.setup({})

_G.dynamo_overseer_window = nil

local open_term_and_watch = function(task)
  if task then
    local main_win = vim.api.nvim_get_current_win()
    overseer.run_action(task, 'open hsplit')
    vim.cmd('resize 8')
    vim.api.nvim_set_current_win(main_win)
  end
end

vim.api.nvim_create_user_command('OverseerRestart', function()
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    overseer.run_template({}, function(task)
      open_term_and_watch(task)
    end)
  else
    overseer.run_action(tasks[1], 'restart')
    open_term_and_watch(overseer.get_by_index(1))
  end
end, {})
