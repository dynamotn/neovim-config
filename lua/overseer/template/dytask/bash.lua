---@module 'overseer'
---@type overseer.TemplateDefinition
return {
  name = 'bash run',
  desc = 'Run bash script',
  builder = function()
    local file = vim.fn.expand('%:p')

    ---@type overseer.TaskDefinition
    return {
      cmd = { 'bash', file },
      components = {
        'output',
      },
    }
  end,
  condition = {
    filetype = 'sh',
  },
  priority = -1,
}
