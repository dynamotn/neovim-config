-- `:DyCron [{expr}]`: a cron schedule in words, with its next runs. The
-- schedules of a crontab, a CronJob or a workflow are read out at the end of
-- their lines; the module only loads for a buffer that has one, which here
-- is a plain search.
vim.api.nvim_create_user_command(
  'DyCron',
  function(args) require('tools.cron').command(args) end,
  {
    nargs = '*',
    desc = 'A cron schedule in words, with its next runs',
  }
)

-- The lines `tools.cron` reads; a schedule further down is not read out
local MAX_LINES = 5000

--- Whether one of the first lines of `bufnr` is a `schedule:` or `cron:` key
---@param bufnr integer
---@return boolean
local function has_schedule(bufnr)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, MAX_LINES, false)) do
    local key = line:match('^%s*%-?%s*(%a+):')
    if key == 'schedule' or key == 'cron' then return true end
  end
  return false
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('dy_cron', { clear = true }),
  pattern = { 'crontab', 'yaml', 'yaml.*' },
  callback = function(args)
    if args.match ~= 'crontab' and not has_schedule(args.buf) then return end
    require('tools.cron').attach(args.buf)
  end,
})
