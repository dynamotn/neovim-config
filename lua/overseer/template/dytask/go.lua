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
      components = {
        'output',
      },
    }
  end,
  condition = {
    filetype = { 'go' },
  },
  priority = -1,
}
