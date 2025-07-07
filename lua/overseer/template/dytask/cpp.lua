---@module 'overseer'
---@type overseer.TemplateDefinition
return {
  name = 'g++ build and run',
  desc = 'Compile C++ to executable and run',
  builder = function()
    local file = vim.fn.expand('%:p')
    local executable = vim.fn.expand('%:p:r')

    ---@type overseer.TaskDefinition
    return {
      cmd = executable,
      components = {
        {
          'dependencies',
          task_names = {
            {
              cmd = 'g++',
              args = { file, '-o', executable },
            },
          },
        },
        'output',
      },
    }
  end,
  condition = {
    filetype = require('config.languages').cpp.filetypes,
  },
  priority = -1,
}
