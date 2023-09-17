return {
  {
    '<F1>',
    function()
      require('neo-tree.command')._command('show', nil, true, true, true)
    end,
    desc = 'File explorer',
  },
  {
    '<Space>ft',
    function()
      require('neo-tree.command')._command('show', nil, true, true, true)
    end,
    desc = 'File explorer',
  },
  {
    '<Space>gt',
    function()
      require('neo-tree.command')._command('show', 'git_status', true, true, true)
    end,
    desc = 'Status explorer',
  },
}
