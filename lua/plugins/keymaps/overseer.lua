local restart = function()
  local open_term_and_watch = function(task)
    if task then
      local main_win = vim.api.nvim_get_current_win()
      require('overseer').run_action(task, 'open hsplit')
      vim.cmd('resize 8')
      vim.api.nvim_set_current_win(main_win)
    end
  end

  local tasks = require('overseer').list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    require('overseer').run_template({}, function(task)
      open_term_and_watch(task)
    end)
  else
    require('overseer').run_action(tasks[1], 'restart')
    open_term_and_watch(require('overseer').get_by_index(1))
  end
end

vim.api.nvim_create_user_command('OverseerRestart', restart, {})

return {
  { '<F5>', restart, desc = 'Run code' },
  { '<Space>rr', restart, desc = 'Run code' },
  {
    '<Space>rt',
    function()
      require('overseer').toggle()
    end,
    desc = 'Toggle ran tasks and jobs',
  },
}
