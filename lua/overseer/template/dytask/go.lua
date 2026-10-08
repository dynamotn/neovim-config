---@module 'overseer'
---@type overseer.TemplateDefinition
return {
  name = 'go run',
  desc = 'Run go file',
  builder = function()
    local file = vim.fn.expand('%:p')

    ---@type overseer.TaskDefinition
    return {
      cmd = { 'go', 'run', file },
      -- `default` sets the status from the exit code
      components = {
        'default',
        'output',
      },
    }
  end,
  condition = {
    filetype = { 'go' },
  },
  priority = -1,
}
