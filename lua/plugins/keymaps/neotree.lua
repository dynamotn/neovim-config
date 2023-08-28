local neotree = require('neo-tree.command')

return {
  {
    '<F1>',
    function()
      neotree._command('show', nil, true, true, true)
    end,
    desc = 'File explorer',
  },
  {
    '<Space>ft',
    function()
      neotree._command('show', nil, true, true, true)
    end,
    desc = 'File explorer',
  },
  {
    '<Space>gt',
    function()
      neotree._command('show', 'git_status', true, true, true)
    end,
    desc = 'Status explorer',
  },
}
